import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/notification_tile.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  ProjectModel? _project;
  List<NotificationModel> _notifications = const [];
  String _ownerName = 'Home Owner';
  String _location = 'Punjab';
  int _unread = 0;
  int _visitCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_reload);
    final cachedList = ProjectService.cachedOwnerProjects;
    final cachedProfile = AuthService.cachedProfile;
    if ((cachedList != null && cachedList.isNotEmpty) ||
        cachedProfile != null) {
      _project =
          (cachedList != null && cachedList.isNotEmpty) ? cachedList.first : null;
      _ownerName = cachedProfile?['full_name'] as String? ?? _ownerName;
      _location = cachedProfile?['location_text'] as String? ??
          cachedProfile?['city'] as String? ??
          _location;
      _notifications = NotificationService.cachedList?.take(5).toList() ??
          const [];
      _unread = NotificationService.cachedUnread ?? 0;
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
    final profile = await AuthService.currentProfile();
    final project = await ProjectService.primaryOwnerProject();
    final notes = await NotificationService.listMine(limit: 5);
    final unread = await NotificationService.unreadCount();
    var visits = 0;
    if (project != null) {
      visits = await ProjectService.visitCountForProject(project.id);
      ProjectService.prefetchDetails(project.id);
    }
    if (!mounted) return;
    setState(() {
      _project = project;
      _notifications = notes;
      _unread = unread;
      _visitCount = visits;
      _ownerName = profile?['full_name'] as String? ?? _ownerName;
      _location = profile?['location_text'] as String? ??
          profile?['city'] as String? ??
          _location;
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
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ProjectService.primaryOwnerProject(forceRefresh: true);
          await AuthService.currentProfile(forceRefresh: true);
          await NotificationService.listMine(forceRefresh: true);
          await _reload();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(
                theme: theme,
                name: _ownerName,
                location: _location,
              ),
              const SizedBox(height: 24),
              if (_loading && project == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    KpiCard(
                      value: project == null
                          ? '0'
                          : '${(project.progress * 100).round()}%',
                      label: 'Progress',
                      icon: Icons.pie_chart_outline,
                      filled: true,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.ownerProject);
                      },
                    ),
                    KpiCard(
                      value: '$_unread',
                      label: 'Alerts',
                      icon: Icons.notifications_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.ownerNotifications);
                      },
                    ),
                    KpiCard(
                      value: '$_visitCount',
                      label: 'Visits',
                      icon: Icons.fact_check_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.ownerVisits);
                      },
                    ),
                    KpiCard(
                      value: project?.nextInspection ?? '—',
                      label: 'Next Visit',
                      icon: Icons.event_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.ownerProject);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'House Overview',
                  actionLabel: 'View All',
                  onActionTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.ownerProject);
                  },
                ),
                const SizedBox(height: 12),
                if (project == null)
                  FluentCard(
                    child: Text(
                      'No house project is linked to this account yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  FluentCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        ProgressRing(
                          progress: project.progress,
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
                                project.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.id,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${project.statusLabel} · ${project.phase}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Engineer: ${project.engineerName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: project.progress,
                                  minHeight: 6,
                                  backgroundColor: AppColors.outlineVariant
                                      .withValues(alpha: 0.3),
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
                const SectionHeader(title: 'Shortcuts'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ShortcutCard(
                        icon: Icons.rate_review_outlined,
                        label: 'Feedback',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.ownerFeedback),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ShortcutCard(
                        icon: Icons.report_problem_outlined,
                        label: 'Complaints',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.ownerComplaints),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ShortcutCard(
                        icon: Icons.folder_outlined,
                        label: 'Documents',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.ownerReports),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'Recent Notifications',
                  actionLabel: 'View All',
                  onActionTap: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.ownerNotifications);
                  },
                ),
                const SizedBox(height: 8),
                if (_notifications.isEmpty)
                  FluentCard(
                    child: Text(
                      'No notifications yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  NotificationCard(notifications: _notifications),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluentCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.theme,
    required this.name,
    required this.location,
  });

  final ThemeData theme;
  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $name',
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
                    Icons.home_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Home Owner',
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
            Expanded(
              child: Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
