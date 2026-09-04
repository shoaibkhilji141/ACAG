import 'package:flutter/material.dart';

import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/notification_tile.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_reload);
    final cached = NotificationService.cachedList;
    if (cached != null) {
      _items = cached;
      _loading = false;
    }
    _reload();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await NotificationService.listMine();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _onTap(NotificationModel item) async {
    final id = item.id;
    if (id != null && !item.isRead) {
      await NotificationService.markRead(id);
    }
  }

  Future<void> _markAll() async {
    await NotificationService.markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = _items.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAll,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await NotificationService.listMine(forceRefresh: true);
          await _reload();
        },
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _items.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.notifications_none_outlined,
                        message:
                            'No notifications yet. Visit updates and announcements will appear here.',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Opacity(
                        opacity: item.isRead ? 0.72 : 1,
                        child: NotificationTile(
                          notification: item,
                          onTap: () => _onTap(item),
                          showDivider: index < _items.length - 1,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
