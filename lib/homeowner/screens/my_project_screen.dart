import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

/// Read-only house / project information for the homeowner.
class MyProjectScreen extends StatefulWidget {
  const MyProjectScreen({super.key});

  @override
  State<MyProjectScreen> createState() => _MyProjectScreenState();
}

class _MyProjectScreenState extends State<MyProjectScreen> {
  ProjectModel? _project;
  bool _loading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_loadBadge);
    final cached = ProjectService.cachedOwnerProjects;
    if (cached != null && cached.isNotEmpty) {
      _project = cached.first;
      _loading = false;
    }
    _reload();
    _loadBadge();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_loadBadge);
    super.dispose();
  }

  Future<void> _loadBadge() async {
    final count = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  Future<void> _reload() async {
    final project = await ProjectService.primaryOwnerProject();
    if (project != null) {
      final bundle = await ProjectService.fetchDetailsBundle(
        project.id,
        fallbackProject: project,
      );
      if (!mounted) return;
      setState(() {
        _project = bundle.project;
        _loading = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _project = null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = _project;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'My Project',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ProjectService.primaryOwnerProject(forceRefresh: true);
          await _reload();
        },
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : project == null
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.home_work_outlined,
                        message: 'No project is linked to this account.',
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      FluentCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.id,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    project.title,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      project.statusLabel,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ProgressRing(
                              progress: project.progress,
                              size: 88,
                              strokeWidth: 8,
                              centerSubtext: 'Done',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'House Information'),
                      const SizedBox(height: 12),
                      FluentCard(
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.tag_outlined,
                              label: 'Project / House ID',
                              value: project.id,
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.home_outlined,
                              label: 'House address',
                              value: project.address.isEmpty
                                  ? '—'
                                  : project.address,
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.location_city_outlined,
                              label: 'City / District / Tehsil',
                              value: [
                                if (project.city.trim().isNotEmpty)
                                  project.city,
                                if (project.district != null &&
                                    project.district!.trim().isNotEmpty)
                                  project.district!,
                                if (project.tehsil != null &&
                                    project.tehsil!.trim().isNotEmpty)
                                  project.tehsil!,
                              ].join(' / ').ifEmpty('—'),
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.straighten_outlined,
                              label: 'Plot size',
                              value: project.plotSizeLabel ?? '—',
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.crop_square_outlined,
                              label: 'Covered area',
                              value: project.coveredAreaLabel ?? '—',
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.layers_outlined,
                              label: 'Number of floors',
                              value: project.storiesLabel ?? '—',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Schedule & Progress'),
                      const SizedBox(height: 12),
                      FluentCard(
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.play_circle_outline,
                              label: 'Construction start date',
                              value: project.startDateLabel ?? '—',
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.flag_outlined,
                              label: 'Expected completion date',
                              value: project.estimatedCompletionLabel ?? '—',
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.timeline_outlined,
                              label: 'Current construction stage',
                              value: project.phase,
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.percent_outlined,
                              label: 'Overall completion',
                              value: '${(project.progress * 100).round()}%',
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.engineering_outlined,
                              label: 'Assigned engineer',
                              value: project.engineerName,
                            ),
                            _divider(),
                            _InfoRow(
                              icon: Icons.event_outlined,
                              label: 'Next visit',
                              value: project.nextInspection,
                            ),
                            if (project.lastVisitLabel != null) ...[
                              _divider(),
                              _InfoRow(
                                icon: Icons.history_outlined,
                                label: 'Last visit',
                                value: project.lastVisitLabel!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: 22,
        color: AppColors.outlineVariant.withValues(alpha: 0.35),
      );
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
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
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
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
