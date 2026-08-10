import 'package:flutter/material.dart';

import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/notification_tile.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionHeader(title: 'Project Updates'),
          const SizedBox(height: 12),
          FluentCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < MockData.ownerUpdates.length; i++)
                  NotificationTile(
                    notification: MockData.ownerUpdates[i],
                    showDivider: i < MockData.ownerUpdates.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'System Alerts'),
          const SizedBox(height: 12),
          FluentCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < MockData.notifications.length; i++)
                  NotificationTile(
                    notification: MockData.notifications[i],
                    showDivider: i < MockData.notifications.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
