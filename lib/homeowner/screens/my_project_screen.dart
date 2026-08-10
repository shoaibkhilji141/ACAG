import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import '../../theme/app_theme.dart';

class MyProjectScreen extends StatelessWidget {
  const MyProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = MockData.primaryProject;
    final progressPercent = (project.progress * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Project',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_work_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${project.address}, ${project.city}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StatusChip(status: project.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Progress',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.outlineVariant.withValues(alpha: 0.35),
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current phase: ${project.phase}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(title: 'Phase Timeline'),
            const SizedBox(height: 12),
            FluentCard(
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    _TimelineTeaserRow(
                      stage: MockData.stages[i],
                      isLast: i == 3,
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.ownerProgress);
                    },
                    child: const Text('View Full Timeline'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Project Sections'),
            const SizedBox(height: 12),
            _ProjectLinkTile(
              icon: Icons.timeline_outlined,
              title: 'View Progress',
              subtitle: 'Track construction stages',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.ownerProgress),
            ),
            const SizedBox(height: 10),
            _ProjectLinkTile(
              icon: Icons.photo_library_outlined,
              title: 'Photos',
              subtitle: 'Site progress gallery',
              onTap: () => Navigator.pushNamed(context, AppRoutes.ownerPhotos),
            ),
            const SizedBox(height: 10),
            _ProjectLinkTile(
              icon: Icons.inventory_2_outlined,
              title: 'Materials',
              subtitle: 'Delivery & supply status',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.ownerMaterials),
            ),
            const SizedBox(height: 10),
            _ProjectLinkTile(
              icon: Icons.description_outlined,
              title: 'Reports',
              subtitle: 'Inspection reports & scores',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.ownerReports),
            ),
            const SizedBox(height: 10),
            _ProjectLinkTile(
              icon: Icons.rate_review_outlined,
              title: 'Feedback',
              subtitle: 'Share your experience',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.ownerFeedback),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'View Full Progress',
              icon: Icons.arrow_forward,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.ownerProgress);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTeaserRow extends StatelessWidget {
  const _TimelineTeaserRow({
    required this.stage,
    required this.isLast,
  });

  final ProgressStage stage;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = stage.completed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.primaryContainer
                    : AppColors.outlineVariant.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed ? Icons.check : Icons.circle_outlined,
                size: 14,
                color: completed ? AppColors.onPrimary : AppColors.outline,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: completed
                    ? AppColors.primaryContainer.withValues(alpha: 0.5)
                    : AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    stage.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          completed ? FontWeight.w600 : FontWeight.w400,
                      color: completed
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  stage.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectLinkTile extends StatelessWidget {
  const _ProjectLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FluentCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}
