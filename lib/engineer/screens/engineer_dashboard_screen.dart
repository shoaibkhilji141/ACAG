import 'package:flutter/material.dart';

import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/notification_tile.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class EngineerDashboardScreen extends StatelessWidget {
  const EngineerDashboardScreen({
    super.key,
    this.onNavigateToProjects,
  });

  final VoidCallback? onNavigateToProjects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpis = MockData.kpis;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AcagAppBar(notificationCount: 12),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(theme: theme),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                KpiCard(
                  value: '${kpis.assigned}',
                  label: 'Assigned',
                  icon: Icons.assignment_outlined,
                  filled: true,
                  onTap: onNavigateToProjects,
                ),
                KpiCard(
                  value: '${kpis.todayInspections}',
                  label: "Today's",
                  icon: Icons.today_outlined,
                ),
                KpiCard(
                  value: '${kpis.pending}',
                  label: 'Pending',
                  icon: Icons.pending_actions_outlined,
                ),
                KpiCard(
                  value: '${kpis.completed}',
                  label: 'Completed',
                  icon: Icons.task_alt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Inspection Overview',
              actionLabel: 'View All',
              onActionTap: onNavigateToProjects,
            ),
            const SizedBox(height: 12),
            FluentCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ProgressRing(
                    progress: kpis.completionPercent / 100,
                    size: 100,
                    strokeWidth: 9,
                    centerSubtext: 'Complete',
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Progress',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have completed ${kpis.completed} of ${kpis.assigned} assigned inspections this month.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: kpis.completionPercent / 100,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.outlineVariant.withValues(alpha: 0.3),
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Recent Notifications',
              actionLabel: 'View All',
              onActionTap: () {},
            ),
            const SizedBox(height: 8),
            NotificationCard(
              notifications: MockData.notifications,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${MockData.engineerName}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.engineering_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Engineer',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.outline,
            ),
            const SizedBox(width: 4),
            Text(
              MockData.engineerLocation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
