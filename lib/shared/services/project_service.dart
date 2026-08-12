import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../utils/mock_data.dart';

class MaterialLine {
  const MaterialLine({
    required this.name,
    required this.unit,
    required this.qty,
  });

  final String name;
  final String unit;
  final String qty;
}

class ProjectService {
  ProjectService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Bumped whenever a module is marked complete — Project Details listens.
  static final ValueNotifier<int> moduleCompletionVersion = ValueNotifier(0);

  static String? get _userId => _client.auth.currentUser?.id;

  static Future<String?> resolveProjectUuid(String projectCodeOrId) async {
    final row = await _client
        .from('projects')
        .select('id')
        .eq('project_code', projectCodeOrId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  static Future<String> _requireUuid(String projectCodeOrId) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) {
      throw Exception('Project not found in database.');
    }
    return uuid;
  }

  static Future<Map<int, bool>> getModuleCompletionMap(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return {};

    final rows = await _client
        .from('project_modules')
        .select('module_no, is_completed')
        .eq('project_id', uuid);

    final map = <int, bool>{};
    for (final row in (rows as List)) {
      final raw = row['module_no'];
      final no = raw is num ? raw.toInt() : int.tryParse('$raw');
      if (no == null) continue;
      map[no] = row['is_completed'] == true;
    }
    return map;
  }

  static int completedModuleCount(Map<int, bool> done) =>
      done.values.where((v) => v).length;

  /// Each completed module = 20% (5 modules → 100%).
  static double progressFromModules(Map<int, bool> done) =>
      (completedModuleCount(done) * 0.20).clamp(0.0, 1.0);

  static String phaseFromModules(Map<int, bool> done) {
    final n = completedModuleCount(done);
    return switch (n) {
      0 => 'Not started',
      1 => 'Planning & Elevation',
      2 => 'Foundation & Structural',
      3 => 'Material Estimation',
      4 => 'Construction Tracking',
      _ => 'Handover complete',
    };
  }

  static Future<void> completeModule({
    required String projectCodeOrId,
    required int moduleNo,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);

    final updated = await _client
        .from('project_modules')
        .update({
          'is_completed': true,
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'completed_by': _userId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('project_id', uuid)
        .eq('module_no', moduleNo)
        .select('id');

    if ((updated as List).isEmpty) {
      throw Exception('Module $moduleNo row missing for this project.');
    }

    final done = await getModuleCompletionMap(projectCodeOrId);
    final progressPct = (progressFromModules(done) * 100).round();
    await _client.from('projects').update({
      'progress_percent': progressPct,
      'current_phase': phaseFromModules(done),
      'status': progressPct >= 100 ? 'completed' : 'in_progress',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uuid);

    moduleCompletionVersion.value++;
  }

  static Future<List<Map<String, dynamic>>> listProjectImages(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return [];

    final rows = await _client
        .from('project_images')
        .select('id, image_base64, caption, created_at')
        .eq('project_id', uuid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  static Future<void> addProjectImageBase64({
    required String projectCodeOrId,
    required String imageBase64,
    String? caption,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client.from('project_images').insert({
      'project_id': uuid,
      'image_base64': imageBase64,
      'caption': caption ?? 'Site photo',
      'uploaded_by': _userId,
    });
  }

  // ── Module 01 ──────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getPlotDimensions(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;
    return await _client
        .from('module01_plot_dimensions')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> savePlotDimensions({
    required String projectCodeOrId,
    required String unit,
    required double length,
    required double width,
    required double totalArea,
    required String geographicZone,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    final now = DateTime.now().toIso8601String();
    await _client.from('module01_plot_dimensions').upsert(
      {
        'project_id': uuid,
        'unit': unit,
        'length': length,
        'width': width,
        'total_area': totalArea,
        'geographic_zone': geographicZone,
        'saved_by': _userId,
        'saved_at': now,
        'updated_at': now,
      },
      onConflict: 'project_id',
    );

    await _client.from('projects').update({
      'plot_size_label': '${length.toStringAsFixed(0)}×${width.toStringAsFixed(0)} $unit',
      'construction_area_sqft': totalArea,
      'updated_at': now,
    }).eq('id', uuid);
  }

  static Future<Map<String, dynamic>?> getRoomRequirements(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;
    return await _client
        .from('module01_room_requirements')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> saveRoomRequirements({
    required String projectCodeOrId,
    required int bedrooms,
    required int bathrooms,
    required int toilets,
    required int kitchens,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    final now = DateTime.now().toIso8601String();
    await _client.from('module01_room_requirements').upsert(
      {
        'project_id': uuid,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'toilets': toilets,
        'kitchens': kitchens,
        'saved_by': _userId,
        'saved_at': now,
        'updated_at': now,
      },
      onConflict: 'project_id',
    );
  }

  static Future<List<Map<String, dynamic>>> getFloorPlans(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return [];
    final rows = await _client
        .from('module01_floor_plans')
        .select()
        .eq('project_id', uuid)
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  static Future<void> saveFloorPlanSelection({
    required String projectCodeOrId,
    required String selectedOptionKey,
    required List<Map<String, dynamic>> options,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client.from('module01_floor_plans').delete().eq('project_id', uuid);
    await _client.from('module01_floor_plans').insert(
      options
          .map(
            (o) => {
              'project_id': uuid,
              'option_key': o['option_key'],
              'title': o['title'],
              'description': o['description'],
              'is_ai_generated': true,
              'is_selected': o['option_key'] == selectedOptionKey,
            },
          )
          .toList(),
    );
  }

  static Future<List<Map<String, dynamic>>> getElevationDesigns(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return [];
    final rows = await _client
        .from('module01_elevation_designs')
        .select()
        .eq('project_id', uuid)
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  static Future<void> saveElevationSelection({
    required String projectCodeOrId,
    required String selectedStyleKey,
    required List<Map<String, dynamic>> styles,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client
        .from('module01_elevation_designs')
        .delete()
        .eq('project_id', uuid);
    await _client.from('module01_elevation_designs').insert(
      styles
          .map(
            (s) => {
              'project_id': uuid,
              'style_key': s['style_key'],
              'title': s['title'],
              'is_ai_suggested': s['style_key'] == 'modern',
              'is_selected': s['style_key'] == selectedStyleKey,
            },
          )
          .toList(),
    );
  }

  // ── Module 02 ──────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getStories(String projectCodeOrId) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;
    return await _client
        .from('module02_stories')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> saveStories({
    required String projectCodeOrId,
    required int storiesCount,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client.from('module02_stories').upsert(
      {
        'project_id': uuid,
        'stories_count': storiesCount,
        'saved_by': _userId,
        'saved_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'project_id',
    );
  }

  static Future<Map<String, dynamic>?> getSoilAnalysis(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;
    return await _client
        .from('module02_soil_analysis')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> saveSoilAnalysis({
    required String projectCodeOrId,
    required String soilType,
    double? bearingCapacity,
    double? waterTableDepth,
    String? recommendedNote,
    String? evidencePhotoBase64,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    final payload = <String, dynamic>{
      'project_id': uuid,
      'soil_type': soilType,
      'bearing_capacity_kn_m2': bearingCapacity,
      'water_table_depth_m': waterTableDepth,
      'recommended_foundation_note': recommendedNote,
      'saved_by': _userId,
      'saved_at': DateTime.now().toIso8601String(),
    };
    if (evidencePhotoBase64 != null) {
      payload['evidence_photo_base64'] = evidencePhotoBase64;
    }
    await _client.from('module02_soil_analysis').upsert(
      payload,
      onConflict: 'project_id',
    );
  }

  static Future<void> saveFoundationDrawing({
    required String projectCodeOrId,
    required Map<String, dynamic> summaryJson,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client.from('module02_foundation_drawing').upsert(
      {
        'project_id': uuid,
        'summary_json': summaryJson,
        'is_ai_suggested': true,
        'confirmed': true,
        'confirmed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'project_id',
    );
  }

  static Future<Map<String, dynamic>?> getStructuralFrame(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;
    return await _client
        .from('module02_structural_frame')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> saveStructuralFrame({
    required String projectCodeOrId,
    required String frameType,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client.from('module02_structural_frame').upsert(
      {
        'project_id': uuid,
        'frame_type': frameType,
        'is_ai_suggested': frameType.contains('RCC'),
        'confirmed': true,
        'confirmed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'project_id',
    );
  }

  // ── Module 03 ──────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getMaterialEstimate(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;
    return await _client
        .from('module03_material_estimates')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<List<MaterialLine>> getMaterialLines(
    String projectCodeOrId,
  ) async {
    final row = await getMaterialEstimate(projectCodeOrId);
    if (row == null) return [];

    String fmt(num? n) {
      if (n == null) return '0';
      if (n == n.roundToDouble()) {
        return n.round().toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );
      }
      return n.toStringAsFixed(1);
    }

    return [
      MaterialLine(
        name: 'Bricks',
        unit: 'Nos.',
        qty: fmt(row['bricks_qty'] as num?),
      ),
      MaterialLine(
        name: 'Cement',
        unit: 'Bags',
        qty: fmt(row['cement_bags'] as num?),
      ),
      MaterialLine(
        name: 'Steel (Sarya)',
        unit: 'Tons',
        qty: fmt(row['steel_tons'] as num?),
      ),
      MaterialLine(
        name: 'Sand (Ravi)',
        unit: 'Cft',
        qty: fmt(row['sand_units'] as num?),
      ),
    ];
  }

  static Future<void> saveMaterialEstimate({
    required String projectCodeOrId,
    required double bricksQty,
    required double cementBags,
    required double steelTons,
    required double sandUnits,
    required double bricksCost,
    required double cementCost,
    required double steelCost,
    required double sandCost,
    required double totalCost,
    double? basedOnPlotArea,
    int? basedOnStories,
  }) async {
    final uuid = await _requireUuid(projectCodeOrId);
    await _client.from('module03_material_estimates').upsert(
      {
        'project_id': uuid,
        'based_on_plot_area': basedOnPlotArea,
        'based_on_stories': basedOnStories,
        'bricks_qty': bricksQty,
        'cement_bags': cementBags,
        'steel_tons': steelTons,
        'sand_units': sandUnits,
        'bricks_cost': bricksCost,
        'cement_cost': cementCost,
        'steel_cost': steelCost,
        'sand_cost': sandCost,
        'total_cost': totalCost,
        'currency': 'PKR',
        'saved_by': _userId,
        'saved_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'project_id',
    );
  }

  static ProjectModel projectFromRouteOrMock(Object? args) {
    return args is ProjectModel ? args : MockData.primaryProject;
  }
}
