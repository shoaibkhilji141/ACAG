import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/notification_tile.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = MockData.primaryProject;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        showAvatar: true,
        avatarInitials: 'AR',
        notificationCount: MockData.ownerUpdates.length,
        onNotificationTap: () {
          Navigator.pushNamed(context, AppRoutes.ownerNotifications);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${MockData.ownerName}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  MockData.ownerLocation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ProjectStatusHero(
              progress: project.progress,
              onViewDetails: () {
                Navigator.pushNamed(context, AppRoutes.ownerProject);
              },
            ),
            const SizedBox(height: 20),
            SectionHeader(title: 'Quick Info'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _QuickInfoTile(
                  icon: Icons.fact_check_outlined,
                  label: 'Inspections Done',
                  value: '4',
                ),
                _QuickInfoTile(
                  icon: Icons.event_outlined,
                  label: 'Next Inspection',
                  value: project.nextInspection,
                ),
                _QuickInfoTile(
                  icon: Icons.engineering_outlined,
                  label: 'Engineer',
                  value: 'Usman Ahmad',
                ),
                _QuickInfoTile(
                  icon: Icons.construction_outlined,
                  label: 'Status',
                  value: '${project.statusLabel} / ${project.phase}',
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recent Updates',
              actionLabel: 'View All',
              onActionTap: () {
                Navigator.pushNamed(context, AppRoutes.ownerNotifications);
              },
            ),
            const SizedBox(height: 12),
            NotificationCard(
              notifications: MockData.ownerUpdates,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Shortcuts'),
            const SizedBox(height: 12),
            _ShortcutRow(
              items: [
                _ShortcutItem(
                  icon: Icons.timeline_outlined,
                  label: 'Progress',
                  route: AppRoutes.ownerProgress,
                ),
                _ShortcutItem(
                  icon: Icons.photo_library_outlined,
                  label: 'Photos',
                  route: AppRoutes.ownerPhotos,
                ),
                _ShortcutItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Materials',
                  route: AppRoutes.ownerMaterials,
                ),
                _ShortcutItem(
                  icon: Icons.rate_review_outlined,
                  label: 'Feedback',
                  route: AppRoutes.ownerFeedback,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectStatusHero extends StatelessWidget {
  const _ProjectStatusHero({
    required this.progress,
    required this.onViewDetails,
  });

  final double progress;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.fluentShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Project Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MockData.primaryProject.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                progress: progress,
                size: 88,
                strokeWidth: 8,
                progressColor: AppColors.onPrimary,
                trackColor: AppColors.onPrimary.withValues(alpha: 0.25),
                centerText: '${(progress * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onPrimary,
                side: BorderSide(
                  color: AppColors.onPrimary.withValues(alpha: 0.6),
                ),
                backgroundColor: AppColors.onPrimary.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View Project Details',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfoTile extends StatelessWidget {
  const _QuickInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FluentCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: (compact
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.titleMedium)
                ?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem {
  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.items});

  final List<_ShortcutItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: FluentCard(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              onTap: () => Navigator.pushNamed(context, items[i].route),
              child: Column(
                children: [
                  Icon(items[i].icon, color: AppColors.primary, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    items[i].label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
