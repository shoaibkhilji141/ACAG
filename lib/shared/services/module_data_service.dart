import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notifies Project Details (and others) to refresh immediately after saves.
class ProjectRefreshBus {
  ProjectRefreshBus._();

  static final ValueNotifier<int> version = ValueNotifier(0);

  static void notify() => version.value++;
}

class ModuleDataService {
  ModuleDataService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<String> _uuid(String projectCodeOrId) async {
    final row = await _client
        .from('projects')
        .select('id')
        .eq('project_code', projectCodeOrId)
        .maybeSingle();
    final id = row?['id'] as String?;
    if (id == null) throw Exception('Project not found in database.');
    return id;
  }

  static String? get _uid => _client.auth.currentUser?.id;

  // ── Module 01 ──────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getPlotDimensions(
    String projectCode,
  ) async {
    final uuid = await _uuid(projectCode);
    return await _client
        .from('module01_plot_dimensions')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> savePlotDimensions({
    required String projectCode,
    required String unit,
    required double length,
    required double width,
    required double totalArea,
    required String geographicZone,
  }) async {
    final uuid = await _uuid(projectCode);
    await _client.from('module01_plot_dimensions').upsert({
      'project_id': uuid,
      'unit': unit,
      'length': length,
      'width': width,
      'total_area': totalArea,
      'geographic_zone': geographicZone,
      'saved_by': _uid,
      'saved_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');

    await _client.from('projects').update({
      'plot_size_label': '${length.toStringAsFixed(0)}×${width.toStringAsFixed(0)} $unit',
      'construction_area_sqft': totalArea,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uuid);
  }

  static Future<Map<String, dynamic>?> getRoomRequirements(
    String projectCode,
  ) async {
    final uuid = await _uuid(projectCode);
    return await _client
        .from('module01_room_requirements')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> saveRoomRequirements({
    required String projectCode,
    required int bedrooms,
    required int bathrooms,
    required int toilets,
    required int kitchens,
  }) async {
    final uuid = await _uuid(projectCode);
    await _client.from('module01_room_requirements').upsert({
      'project_id': uuid,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'toilets': toilets,
      'kitchens': kitchens,
      'saved_by': _uid,
      'saved_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');
  }

  static Future<String?> getSelectedFloorPlanKey(String projectCode) async {
    final uuid = await _uuid(projectCode);
    final row = await _client
        .from('module01_floor_plans')
        .select('option_key')
        .eq('project_id', uuid)
        .eq('is_selected', true)
        .maybeSingle();
    return row?['option_key'] as String?;
  }

  static Future<void> saveFloorPlanSelection({
    required String projectCode,
    required String optionKey,
    required String title,
    String? description,
  }) async {
    final uuid = await _uuid(projectCode);
    final options = [
      (
        key: 'plan_a',
        title: 'Plan A — Compact Layout',
        description: '1,850 sq.ft compact layout',
      ),
      (
        key: 'plan_b',
        title: 'Plan B — Open Living',
        description: '1,920 sq.ft open living',
      ),
    ];

    await _client.from('module01_floor_plans').delete().eq('project_id', uuid);

    await _client.from('module01_floor_plans').insert([
      for (final o in options)
        {
          'project_id': uuid,
          'option_key': o.key,
          'title': o.title,
          'description': o.description,
          'is_ai_generated': true,
          'is_selected': o.key == optionKey,
        },
    ]);
  }

  static Future<String?> getSelectedElevationKey(String projectCode) async {
    final uuid = await _uuid(projectCode);
    final row = await _client
        .from('module01_elevation_designs')
        .select('style_key')
        .eq('project_id', uuid)
        .eq('is_selected', true)
        .maybeSingle();
    return row?['style_key'] as String?;
  }

  static Future<void> saveElevationSelection({
    required String projectCode,
    required String styleKey,
    required String title,
  }) async {
    final uuid = await _uuid(projectCode);
    final styles = [
      (key: 'modern', title: 'Modern'),
      (key: 'traditional', title: 'Traditional'),
      (key: 'contemporary', title: 'Contemporary'),
    ];

    await _client
        .from('module01_elevation_designs')
        .delete()
        .eq('project_id', uuid);

    await _client.from('module01_elevation_designs').insert([
      for (final s in styles)
        {
          'project_id': uuid,
          'style_key': s.key,
          'title': s.title,
          'is_ai_suggested': s.key == 'modern',
          'is_selected': s.key == styleKey,
        },
    ]);
  }

  // ── Module 02 ──────────────────────────────────────────────

  static Future<int?> getStories(String projectCode) async {
    final uuid = await _uuid(projectCode);
    final row = await _client
        .from('module02_stories')
        .select('stories_count')
        .eq('project_id', uuid)
        .maybeSingle();
    final v = row?['stories_count'];
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  static Future<void> saveStories({
    required String projectCode,
    required int stories,
  }) async {
    final uuid = await _uuid(projectCode);
    await _client.from('module02_stories').upsert({
      'project_id': uuid,
      'stories_count': stories,
      'saved_by': _uid,
      'saved_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');
  }

  static Future<Map<String, dynamic>?> getSoilAnalysis(
    String projectCode,
  ) async {
    final uuid = await _uuid(projectCode);
    return await _client
        .from('module02_soil_analysis')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<void> saveSoilAnalysis({
    required String projectCode,
    required String soilType,
    double? bearingCapacity,
    double? waterTableDepth,
    String? note,
    String? evidenceBase64,
  }) async {
    final uuid = await _uuid(projectCode);
    await _client.from('module02_soil_analysis').upsert({
      'project_id': uuid,
      'soil_type': soilType,
      'bearing_capacity_kn_m2': bearingCapacity,
      'water_table_depth_m': waterTableDepth,
      'recommended_foundation_note': note,
      if (evidenceBase64 != null) 'evidence_photo_base64': evidenceBase64,
      'saved_by': _uid,
      'saved_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');
  }

  static Future<void> saveFoundationConfirmed({
    required String projectCode,
    Map<String, dynamic>? summary,
  }) async {
    final uuid = await _uuid(projectCode);
    await _client.from('module02_foundation_drawing').upsert({
      'project_id': uuid,
      'summary_json': summary,
      'is_ai_suggested': true,
      'confirmed': true,
      'confirmed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');
  }

  static Future<String?> getStructuralFrame(String projectCode) async {
    final uuid = await _uuid(projectCode);
    final row = await _client
        .from('module02_structural_frame')
        .select('frame_type')
        .eq('project_id', uuid)
        .maybeSingle();
    return row?['frame_type'] as String?;
  }

  static Future<void> saveStructuralFrame({
    required String projectCode,
    required String frameType,
  }) async {
    final uuid = await _uuid(projectCode);
    await _client.from('module02_structural_frame').upsert({
      'project_id': uuid,
      'frame_type': frameType,
      'is_ai_suggested': frameType.contains('RCC'),
      'confirmed': true,
      'confirmed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');
  }

  // ── Module 03 ──────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getMaterialEstimate(
    String projectCode,
  ) async {
    final uuid = await _uuid(projectCode);
    return await _client
        .from('module03_material_estimates')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  /// Materials shown on Project Details (name + qty only).
  static Future<List<({String name, String qty, String unit})>>
      getMaterialsForDisplay(String projectCode) async {
    final row = await getMaterialEstimate(projectCode);
    if (row == null) return [];

    String fmt(dynamic v) {
      if (v == null) return '—';
      if (v is num) {
        if (v == v.roundToDouble()) return v.toInt().toString();
        return v.toString();
      }
      return '$v';
    }

    return [
      (name: 'Bricks', qty: fmt(row['bricks_qty']), unit: 'Nos.'),
      (name: 'Cement', qty: fmt(row['cement_bags']), unit: 'Bags'),
      (name: 'Steel (Sarya)', qty: fmt(row['steel_tons']), unit: 'Tons'),
      (name: 'Sand (Ravi)', qty: fmt(row['sand_units']), unit: 'Cft'),
    ];
  }

  static Future<void> saveMaterialEstimate({
    required String projectCode,
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
    final uuid = await _uuid(projectCode);
    await _client.from('module03_material_estimates').upsert({
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
      'saved_by': _uid,
      'saved_at': DateTime.now().toIso8601String(),
    }, onConflict: 'project_id');
  }

  // ── Project meta helpers ───────────────────────────────────

  static Future<Map<String, dynamic>?> getProjectMeta(String projectCode) async {
    return await _client
        .from('projects')
        .select(
          'plot_size_label, construction_area_sqft, progress_percent, current_phase, assigned_date, estimated_completion, next_inspection_at',
        )
        .eq('project_code', projectCode)
        .maybeSingle();
  }
}
