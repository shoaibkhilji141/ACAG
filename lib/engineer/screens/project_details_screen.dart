import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/status_chip.dart';
import '../../theme/app_theme.dart';

ProjectModel projectFromRoute(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  return args is ProjectModel ? args : MockData.primaryProject;
}

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'project-progress-${project.id}',
              child: Material(
                color: Colors.transparent,
                child: FluentCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ProgressRing(
                        progress: project.progress,
                        size: 88,
                        strokeWidth: 8,
                        centerSubtext: 'Done',
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.phase,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            StatusChip(status: project.status),
                            const SizedBox(height: 8),
                            Text(
                              '${(project.progress * 100).round()}% construction complete',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Owner',
                    value: project.ownerName,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: '${project.address}, ${project.city}',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.layers_outlined,
                    label: 'Current Phase',
                    value: project.phase,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.event_outlined,
                    label: 'Next Inspection',
                    value: project.nextInspection,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.gps_fixed,
              label: 'GPS Verification',
              subtitle: 'Verify on-site location',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.engineerGps,
                arguments: project,
              ),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.upload_file_outlined,
              label: 'Upload Progress',
              subtitle: 'Submit stage update & photos',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.engineerUpload,
                arguments: project,
              ),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.camera_alt_outlined,
              label: 'Start Inspection',
              subtitle: 'Capture site photos for AI validation',
              color: AppColors.primaryContainer,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.engineerCamera,
                arguments: project,
              ),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.assessment_outlined,
              label: 'View Report',
              subtitle: 'Latest inspection report',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.engineerReport,
                arguments: project,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? AppColors.primary;

    return FluentCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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
