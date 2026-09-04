import 'dart:async';

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

  static List<NotificationModel>? _cache;
  static int? _cachedUnread;
  static DateTime? _cacheAt;
  static Timer? _pollTimer;
  static String? _pollUserId;

  static const _cacheTtl = Duration(seconds: 12);

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

  static void invalidateCache() {
    _cache = null;
    _cachedUnread = null;
    _cacheAt = null;
  }

  static List<NotificationModel>? get cachedList => _cache;
  static int? get cachedUnread => _cachedUnread;

  /// Poll DB every [interval] for new/changed notifications.
  static void startPolling({Duration interval = const Duration(seconds: 15)}) {
    final uid = _userId;
    if (uid == null) return;
    if (_pollTimer != null && _pollUserId == uid) return;
    stopPolling();
    _pollUserId = uid;
    _pollTimer = Timer.periodic(interval, (_) {
      unawaited(refreshQuietly());
    });
    unawaited(refreshQuietly());
  }

  static void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollUserId = null;
  }

  /// Lightweight refresh used by the 15s poller.
  static Future<void> refreshQuietly() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(50);
      final items = (rows as List)
          .map((r) => fromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
      final unread = items.where((n) => !n.isRead).length;
      final changed = _cache == null ||
          _cachedUnread != unread ||
          _cache!.length != items.length ||
          (_cache!.isNotEmpty &&
              items.isNotEmpty &&
              _cache!.first.id != items.first.id);
      _cache = items;
      _cachedUnread = unread;
      _cacheAt = DateTime.now();
      if (changed) version.value++;
    } catch (e) {
      debugPrint('NotificationService.refreshQuietly: $e');
    }
  }

  static Future<List<NotificationModel>> listMine({
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    final uid = _userId;
    if (uid == null) return const [];

    final fresh = _cacheAt != null &&
        DateTime.now().difference(_cacheAt!) < _cacheTtl;
    if (!forceRefresh && _cache != null && fresh) {
      return _cache!.take(limit).toList();
    }

    try {
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      final items = (rows as List)
          .map((r) => fromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
      _cache = items;
      _cachedUnread = items.where((n) => !n.isRead).length;
      _cacheAt = DateTime.now();
      return items;
    } catch (e) {
      debugPrint('NotificationService.listMine: $e');
      return _cache ?? const [];
    }
  }

  static Future<int> unreadCount({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedUnread != null) {
      final fresh = _cacheAt != null &&
          DateTime.now().difference(_cacheAt!) < _cacheTtl;
      if (fresh) return _cachedUnread!;
    }
    final items = await listMine(forceRefresh: forceRefresh);
    return items.where((n) => !n.isRead).length;
  }

  static Future<void> markRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      invalidateCache();
      version.value++;
      await refreshQuietly();
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
      invalidateCache();
      version.value++;
      await refreshQuietly();
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
      if (userId == _userId) {
        invalidateCache();
        version.value++;
      }
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
