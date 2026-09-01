import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/construction_stages.dart';
import '../models/models.dart';
import '../models/project_details_bundle.dart';
import '../utils/mock_data.dart';
import '../utils/project_route.dart';

class ProjectService {
  ProjectService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Bumped whenever a module is marked complete — Project Details listens.
  static final ValueNotifier<int> moduleCompletionVersion = ValueNotifier(0);

  static String? get _userId => _client.auth.currentUser?.id;

  static final Map<String, String> _uuidCache = {};
  static final Map<String, ProjectDetailsBundle> _bundleCache = {};
  static List<ProjectModel>? _assignedProjectsCache;

  static List<ProjectModel>? get cachedAssignedProjects => _assignedProjectsCache;

  static ProjectDetailsBundle? getCachedBundle(String projectCode) =>
      _bundleCache[projectCode];

  static void prefetchDetails(String projectCode) {
    fetchDetailsBundle(projectCode);
  }

  static void invalidateProjectCache([String? projectCode]) {
    if (projectCode != null) {
      _bundleCache.remove(projectCode);
    } else {
      _bundleCache.clear();
    }
    _assignedProjectsCache = null;
  }

  static Future<String?> resolveProjectUuid(String projectCodeOrId) async {
    final cached = _uuidCache[projectCodeOrId];
    if (cached != null) return cached;

    var row = await _client
        .from('projects')
        .select('id')
        .eq('project_code', projectCodeOrId)
        .maybeSingle();
    row ??= await _client
        .from('projects')
        .select('id')
        .eq('id', projectCodeOrId)
        .maybeSingle();

    final uuid = row?['id'] as String?;
    if (uuid != null) _uuidCache[projectCodeOrId] = uuid;
    return uuid;
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
    invalidateProjectCache(projectCodeOrId);
  }

  static Future<List<ProjectModel>> listAssignedProjects() async {
    try {
      var query = _client.from('projects').select();
      final uid = _userId;
      if (uid != null) {
        query = query.eq('assigned_engineer_id', uid);
      }
      final rows = await query.order('updated_at', ascending: false);
      final projects = (rows as List)
          .map((r) => projectFromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
      if (projects.isNotEmpty) {
        _assignedProjectsCache = projects;
        for (final p in projects) {
          fetchDetailsBundle(p.id, fallbackProject: p);
        }
        return projects;
      }

      final demo = await _fetchProjectRow('ACAG-1');
      if (demo != null) {
        final project = projectFromRow(demo);
        _assignedProjectsCache = [project];
        fetchDetailsBundle(project.id, fallbackProject: project);
        return [project];
      }
    } catch (e) {
      debugPrint('listAssignedProjects: $e');
    }

    _assignedProjectsCache = MockData.projects;
    return MockData.projects;
  }

  static Future<Map<String, dynamic>?> _fetchProjectRow(String codeOrId) async {
    var row = await _client
        .from('projects')
        .select()
        .eq('project_code', codeOrId)
        .maybeSingle();
    row ??= await _client
        .from('projects')
        .select()
        .eq('id', codeOrId)
        .maybeSingle();
    return row;
  }

  static String? _phoneFromRow(Map<String, dynamic> row) {
    final phone = row['owner_phone'] as String?;
    if (phone != null && phone.trim().isNotEmpty) return phone.trim();
    return null;
  }

  static ProjectModel projectFromRow(Map<String, dynamic> row) {
    final code = row['project_code'] as String? ?? row['id']?.toString() ?? '';
    final progressPct = (row['progress_percent'] as num?)?.toDouble() ?? 0;
    final statusRaw = (row['status'] as String?)?.toLowerCase() ?? 'in_progress';
    final status = switch (statusRaw) {
      'pending' => ProjectStatus.pending,
      'completed' => ProjectStatus.completed,
      'overdue' => ProjectStatus.overdue,
      _ => ProjectStatus.inProgress,
    };

    var nextInspection = '—';
    final nextRaw = row['next_inspection_at'];
    if (nextRaw is String) {
      final parsed = DateTime.tryParse(nextRaw);
      if (parsed != null) {
        nextInspection = DateFormat('dd MMM yyyy').format(parsed);
      }
    } else if (row['next_inspection'] is String) {
      nextInspection = row['next_inspection'] as String;
    }

    return ProjectModel(
      id: code,
      title: row['title'] as String? ?? 'House #$code',
      address: row['address'] as String? ??
          row['address_line'] as String? ??
          row['site_address'] as String? ??
          '',
      city: row['city'] as String? ?? '',
      ownerName: row['owner_name'] as String? ?? 'Owner',
      ownerPhone: _phoneFromRow(row),
      engineerName: row['engineer_name'] as String? ?? 'Engineer',
      progress: (progressPct / 100).clamp(0.0, 1.0),
      status: status,
      phase: row['current_phase'] as String? ?? 'Not started',
      nextInspection: nextInspection,
      lat: (row['lat'] as num?)?.toDouble() ??
          (row['latitude'] as num?)?.toDouble() ??
          31.5204,
      lng: (row['lng'] as num?)?.toDouble() ??
          (row['longitude'] as num?)?.toDouble() ??
          74.3587,
    );
  }

  static Future<ProjectDetailsBundle> fetchDetailsBundle(
    String projectCodeOrId, {
    ProjectModel? fallbackProject,
  }) async {
    final fallback = fallbackProject ?? MockData.primaryProject;

    try {
      final row = await _fetchProjectRow(projectCodeOrId);
      if (row == null) {
        return ProjectDetailsBundle(
          project: fallback,
          moduleDone: const {},
          images: const [],
          materials: const [],
        );
      }

      final project = projectFromRow(row);
      final code = project.id;
      final uuid = row['id'] as String;
      _uuidCache[code] = uuid;
      _uuidCache[projectCodeOrId] = uuid;

      final results = await Future.wait<dynamic>([
        _moduleMapForUuid(uuid),
        _imagesForUuid(uuid),
        _materialLinesForUuid(uuid),
        _plotForUuid(uuid),
        _constructionStagesForUuid(uuid),
      ]);

      final bundle = ProjectDetailsBundle(
        project: project,
        moduleDone: results[0] as Map<int, bool>,
        images: results[1] as List<Map<String, dynamic>>,
        materials: results[2] as List<MaterialLine>,
        plot: results[3] as Map<String, dynamic>?,
        ownerPhone: _phoneFromRow(row) ?? project.ownerPhone,
        constructionStages: results[4] as List<Map<String, dynamic>>,
      );
      _bundleCache[code] = bundle;
      return bundle;
    } catch (e) {
      debugPrint('fetchDetailsBundle: $e');
      return _bundleCache[projectCodeOrId] ??
          ProjectDetailsBundle(
            project: fallback,
            moduleDone: const {},
            images: const [],
            materials: const [],
          );
    }
  }

  static Future<Map<int, bool>> _moduleMapForUuid(String uuid) async {
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

  static Future<List<Map<String, dynamic>>> _imagesForUuid(String uuid) async {
    final rows = await _client
        .from('project_images')
        .select('id, image_base64, caption, created_at')
        .eq('project_id', uuid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows as List);
  }

  static Future<List<MaterialLine>> _materialLinesForUuid(String uuid) async {
    final row = await _client
        .from('module03_material_estimates')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
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

  static Future<Map<String, dynamic>?> _plotForUuid(String uuid) async {
    return await _client
        .from('module01_plot_dimensions')
        .select()
        .eq('project_id', uuid)
        .maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> _constructionStagesForUuid(
    String uuid,
  ) async {
    try {
      final rows = await _client
          .from('module04_construction_stages')
          .select()
          .eq('project_id', uuid)
          .order('stage_no');
      return List<Map<String, dynamic>>.from(rows as List);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205' ||
          e.message.contains('module04_construction_stages')) {
        return [];
      }
      rethrow;
    }
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
    invalidateProjectCache(projectCodeOrId);
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
        'saved_by': _userId,
        'saved_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'project_id',
    );
  }

  static ProjectModel projectFromRouteOrMock(Object? args) {
    if (args is StitchRouteArgs) return args.project;
    return args is ProjectModel ? args : MockData.primaryProject;
  }

  // ── Module 04 — Construction Tracking ─────────────────────

  static Future<List<Map<String, dynamic>>> getConstructionStages(
    String projectCodeOrId,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return [];
    return _constructionStagesForUuid(uuid);
  }

  static Future<Map<String, dynamic>?> getConstructionStage(
    String projectCodeOrId,
    int stageNo,
  ) async {
    final uuid = await resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return null;

    try {
      return await _client
          .from('module04_construction_stages')
          .select()
          .eq('project_id', uuid)
          .eq('stage_no', stageNo)
          .maybeSingle();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205' ||
          e.message.contains('module04_construction_stages')) {
        return null;
      }
      rethrow;
    }
  }

  static int completedConstructionStageCount(List<Map<String, dynamic>> rows) =>
      rows.length;

  static int nextConstructionStageNo(List<Map<String, dynamic>> rows) =>
      completedConstructionStageCount(rows) + 1;

  static Future<bool> saveConstructionStage({
    required String projectCodeOrId,
    required int stageNo,
    required String stageName,
    required List<String> imageBase64List,
    required String description,
  }) async {
    if (imageBase64List.isEmpty) {
      throw Exception('At least one progress photo is required.');
    }

    final uuid = await _requireUuid(projectCodeOrId);
    final now = DateTime.now().toIso8601String();
    final primaryImage = imageBase64List.first;

    try {
      await _client.from('module04_construction_stages').upsert(
        {
          'project_id': uuid,
          'stage_no': stageNo,
          'stage_name': stageName,
          'image_base64': primaryImage,
          'images_json': imageBase64List,
          'description': description,
          'completed_at': now,
          'completed_by': _userId,
        },
        onConflict: 'project_id,stage_no',
      );
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205' ||
          e.message.contains('module04_construction_stages')) {
        throw Exception(
          'Database table missing. Run supabase/migrations/20250828140000_module04_construction_stages.sql in Supabase SQL Editor.',
        );
      }
      rethrow;
    }

    final baseCaption = description.trim().isEmpty
        ? '$stageName — progress photo'
        : '$stageName — $description';

    for (var i = 0; i < imageBase64List.length; i++) {
      final suffix = imageBase64List.length > 1
          ? ' (${i + 1}/${imageBase64List.length})'
          : '';
      await addProjectImageBase64(
        projectCodeOrId: projectCodeOrId,
        imageBase64: imageBase64List[i],
        caption: '$baseCaption$suffix',
      );
    }

    if (stageNo >= ConstructionStages.total) {
      await completeModule(projectCodeOrId: projectCodeOrId, moduleNo: 4);
      return true;
    } else {
      moduleCompletionVersion.value++;
      invalidateProjectCache(projectCodeOrId);
      return false;
    }
  }

  static List<String> stageImagesFromRow(Map<String, dynamic>? row) {
    if (row == null) return [];
    final json = row['images_json'];
    if (json is List && json.isNotEmpty) {
      return json
          .map((e) => e?.toString() ?? '')
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    final single = row['image_base64'] as String?;
    if (single != null && single.trim().isNotEmpty) return [single];
    return [];
  }

  static Future<String?> getOwnerPhone(String projectCodeOrId) async {
    final row = await _client
        .from('projects')
        .select('owner_phone')
        .eq('project_code', projectCodeOrId)
        .maybeSingle();
    final phone = row?['owner_phone'] as String?;
    if (phone != null && phone.trim().isNotEmpty) return phone.trim();
    return null;
  }
}
