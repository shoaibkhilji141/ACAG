import 'package:flutter/material.dart';

import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/notification_tile.dart';
import '../../theme/app_theme.dart';

class EngineerNotificationsScreen extends StatefulWidget {
  const EngineerNotificationsScreen({super.key});

  @override
  State<EngineerNotificationsScreen> createState() =>
      _EngineerNotificationsScreenState();
}

class _EngineerNotificationsScreenState
    extends State<EngineerNotificationsScreen> {
  List<NotificationModel> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
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
      await _reload();
    }
  }

  Future<void> _markAll() async {
    await NotificationService.markAllRead();
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = _items.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Notifications',
        showBranding: false,
        notificationCount: unread,
      ),
      body: Column(
        children: [
          if (unread > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _markAll,
                  child: const Text('Mark all read'),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
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
                                  'Module completions and site visits will appear here.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Opacity(
                              opacity: item.isRead ? 0.7 : 1,
                              child: NotificationTile(
                                notification: item,
                                onTap: () => _onTap(item),
                                showDivider: index < _items.length - 1,
                              ),
                            );
                          },
                        ),
            ),
          ),
          if (!_loading && _items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${_items.length} notification${_items.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
