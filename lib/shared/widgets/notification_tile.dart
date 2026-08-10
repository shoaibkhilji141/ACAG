import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../models/models.dart';
import 'app_card.dart';

/// Notification list item for engineer / owner feeds.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.showDivider = true,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final bool showDivider;

  static _NotificationStyle _styleFor(NotificationType type) {
    return switch (type) {
      NotificationType.warning => _NotificationStyle(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          background: AppColors.tertiaryFixed.withValues(alpha: 0.5),
        ),
      NotificationType.info => _NotificationStyle(
          icon: Icons.info_outline,
          color: AppColors.info,
          background: AppColors.secondaryContainer,
        ),
      NotificationType.success => _NotificationStyle(
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          background: AppColors.primaryFixed.withValues(alpha: 0.35),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleFor(notification.type);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: style.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(style.icon, color: style.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    notification.timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}

/// Card-wrapped variant for grouped notification sections.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notifications,
    this.onNotificationTap,
  });

  final List<NotificationModel> notifications;
  final ValueChanged<NotificationModel>? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return FluentCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < notifications.length; i++)
            NotificationTile(
              notification: notifications[i],
              onTap: onNotificationTap != null
                  ? () => onNotificationTap!(notifications[i])
                  : null,
              showDivider: i < notifications.length - 1,
            ),
        ],
      ),
    );
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;
}
