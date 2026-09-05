import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';
import 'project_service.dart';

class OwnerService {
  OwnerService._();

  static SupabaseClient get _client => Supabase.instance.client;
  static String? get _userId => _client.auth.currentUser?.id;

  static final Map<String, List<Map<String, dynamic>>> _docsCache = {};
  static final Map<String, List<Map<String, dynamic>>> _complaintsCache = {};

  static void invalidateCaches([String? projectCode]) {
    if (projectCode != null) {
      _docsCache.remove(projectCode);
      _complaintsCache.remove(projectCode);
    } else {
      _docsCache.clear();
      _complaintsCache.clear();
    }
  }

  // ── Feedback / ratings ─────────────────────────────────────

  static Future<void> submitFeedback({
    required String projectCodeOrId,
    required int rating,
    String? category,
    String? comments,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Please login again.');
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }

    final uuid = await ProjectService.resolveProjectUuid(projectCodeOrId);
    if (uuid == null) throw Exception('Project not found.');

    await _client.from('owner_feedback').insert({
      'project_id': uuid,
      'owner_id': uid,
      'rating': rating,
      'category': category,
      'comments': comments?.trim().isEmpty == true ? null : comments?.trim(),
    });

    await NotificationService.notifyProjectParties(
      projectUuid: uuid,
      title: 'New owner feedback',
      body: 'Owner submitted a $rating-star rating'
          '${category != null ? ' ($category)' : ''}.',
      type: 'info',
      category: 'feedback',
      includeOwner: false,
      includeEngineer: true,
    );
  }

  // ── Documents ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listDocuments(
    String projectCodeOrId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _docsCache[projectCodeOrId] != null) {
      return _docsCache[projectCodeOrId]!;
    }
    final uuid = await ProjectService.resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return const [];

    try {
      final rows = await _client
          .from('project_documents')
          .select()
          .eq('project_id', uuid)
          .order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(rows as List);
      _docsCache[projectCodeOrId] = list;
      return list;
    } catch (e) {
      debugPrint('OwnerService.listDocuments: $e');
      return _docsCache[projectCodeOrId] ?? const [];
    }
  }

  // ── Complaints ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listComplaints(
    String projectCodeOrId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _complaintsCache[projectCodeOrId] != null) {
      return _complaintsCache[projectCodeOrId]!;
    }
    final uuid = await ProjectService.resolveProjectUuid(projectCodeOrId);
    if (uuid == null) return const [];

    try {
      final rows = await _client
          .from('complaints')
          .select()
          .eq('project_id', uuid)
          .order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(rows as List);
      _complaintsCache[projectCodeOrId] = list;
      return list;
    } catch (e) {
      debugPrint('OwnerService.listComplaints: $e');
      return _complaintsCache[projectCodeOrId] ?? const [];
    }
  }

  static Future<void> submitComplaint({
    required String projectCodeOrId,
    required String category,
    required String description,
    required String priority,
    String? locationText,
    List<String> photoBase64List = const [],
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Please login again.');

    final uuid = await ProjectService.resolveProjectUuid(projectCodeOrId);
    if (uuid == null) throw Exception('Project not found.');

    final now = DateTime.now().toIso8601String();
    await _client.from('complaints').insert({
      'project_id': uuid,
      'raised_by': uid,
      'category': category.trim(),
      'description': description.trim(),
      'priority': priority,
      'status': 'submitted',
      'location_text': locationText?.trim().isEmpty == true
          ? null
          : locationText?.trim(),
      'photo_base64':
          photoBase64List.isEmpty ? null : photoBase64List.first,
      'photos_json': photoBase64List,
      'created_at': now,
      'updated_at': now,
    });

    invalidateCaches(projectCodeOrId);

    await NotificationService.notifyProjectParties(
      projectUuid: uuid,
      title: 'New complaint submitted',
      body: '$category — ${description.trim()}',
      type: 'warning',
      category: 'complaint_update',
    );
  }
}
