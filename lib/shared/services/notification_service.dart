import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

class NotificationService {
  NotificationService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static String? get _userId => _client.auth.currentUser?.id;

  /// Bumped when notifications change so app bars / dashboards can refresh.
  static final ValueNotifier<int> version = ValueNotifier(0);

  static NotificationType _typeFromRaw(String? raw) {
    return switch ((raw ?? '').toLowerCase()) {
      'warning' => NotificationType.warning,
      'success' => NotificationType.success,
      _ => NotificationType.info,
    };
  }

  static String _timeAgo(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(createdAt.toLocal());
  }

  static NotificationModel fromRow(Map<String, dynamic> row) {
    final createdRaw = row['created_at'];
    DateTime? createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw);
    }
    return NotificationModel(
      id: row['id']?.toString(),
      title: row['title'] as String? ?? 'Notification',
      subtitle: row['body'] as String? ?? '',
      timeAgo: _timeAgo(createdAt),
      type: _typeFromRaw(row['type'] as String?),
      isRead: row['is_read'] == true,
      category: row['category'] as String?,
      projectId: row['project_id']?.toString(),
      createdAt: createdAt,
    );
  }

  static Future<List<NotificationModel>> listMine({int limit = 50}) async {
    final uid = _userId;
    if (uid == null) return const [];

    try {
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => fromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('NotificationService.listMine: $e');
      return const [];
    }
  }

  static Future<int> unreadCount() async {
    final uid = _userId;
    if (uid == null) return 0;
    try {
      final rows = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);
      return (rows as List).length;
    } catch (e) {
      debugPrint('NotificationService.unreadCount: $e');
      return 0;
    }
  }

  static Future<void> markRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      version.value++;
    } catch (e) {
      debugPrint('NotificationService.markRead: $e');
    }
  }

  static Future<void> markAllRead() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
      version.value++;
    } catch (e) {
      debugPrint('NotificationService.markAllRead: $e');
    }
  }

  static Future<void> notifyUser({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
    String? category,
    String? projectUuid,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'project_id': projectUuid,
        'title': title,
        'body': body,
        'type': type,
        'category': category ?? type,
        'is_read': false,
      });
      version.value++;
    } catch (e) {
      debugPrint('NotificationService.notifyUser: $e');
    }
  }

  static Future<void> notifyProjectParties({
    required String projectUuid,
    required String title,
    required String body,
    String type = 'info',
    String? category,
    bool includeEngineer = true,
    bool includeOwner = true,
  }) async {
    try {
      final row = await _client
          .from('projects')
          .select('assigned_engineer_id, owner_user_id')
          .eq('id', projectUuid)
          .maybeSingle();
      if (row == null) return;

      final engineerId = row['assigned_engineer_id'] as String?;
      final ownerId = row['owner_user_id'] as String?;
      final targets = <String>{};
      if (includeEngineer && engineerId != null) targets.add(engineerId);
      if (includeOwner && ownerId != null) targets.add(ownerId);

      for (final uid in targets) {
        await notifyUser(
          userId: uid,
          title: title,
          body: body,
          type: type,
          category: category,
          projectUuid: projectUuid,
        );
      }
    } catch (e) {
      debugPrint('NotificationService.notifyProjectParties: $e');
    }
  }
}
