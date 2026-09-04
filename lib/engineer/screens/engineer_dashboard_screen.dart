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

class EngineerDashboardScreen extends StatefulWidget {
  const EngineerDashboardScreen({
    super.key,
    this.onNavigateToProjects,
  });

  final VoidCallback? onNavigateToProjects;

  @override
  State<EngineerDashboardScreen> createState() =>
      _EngineerDashboardScreenState();
}

class _EngineerDashboardScreenState extends State<EngineerDashboardScreen> {
  List<ProjectModel> _projects = const [];
  List<NotificationModel> _notifications = const [];
  String _engineerName = 'Engineer';
  String _location = 'Punjab';
  int _unread = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_reload);
    ProjectService.moduleCompletionVersion.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_reload);
    ProjectService.moduleCompletionVersion.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final projects = await ProjectService.listAssignedProjects();
    final notifications = await NotificationService.listMine(limit: 5);
    final unread = await NotificationService.unreadCount();
    final profile = await AuthService.currentProfile();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _notifications = notifications;
      _unread = unread;
      _engineerName =
          profile?['full_name'] as String? ?? _engineerName;
      _location = profile?['location_text'] as String? ??
          profile?['city'] as String? ??
          _location;
      _loading = false;
    });
  }

  int get _assigned => _projects.length;
  int get _completed =>
      _projects.where((p) => p.status == ProjectStatus.completed).length;
  int get _pending =>
      _projects.where((p) => p.status != ProjectStatus.completed).length;
  double get _avgProgress {
    if (_projects.isEmpty) return 0;
    final sum = _projects.fold<double>(0, (a, p) => a + p.progress);
    return sum / _projects.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.engineerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(
                theme: theme,
                name: _engineerName,
                location: _location,
              ),
              const SizedBox(height: 24),
              if (_loading)
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
                      value: '$_assigned',
                      label: 'Assigned',
                      icon: Icons.assignment_outlined,
                      filled: true,
                      onTap: widget.onNavigateToProjects,
                    ),
                    KpiCard(
                      value: '$_unread',
                      label: 'Alerts',
                      icon: Icons.notifications_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.engineerNotifications);
                      },
                    ),
                    KpiCard(
                      value: '$_pending',
                      label: 'Pending',
                      icon: Icons.pending_actions_outlined,
                      onTap: widget.onNavigateToProjects,
                    ),
                    KpiCard(
                      value: '$_completed',
                      label: 'Completed',
                      icon: Icons.task_alt_outlined,
                      onTap: widget.onNavigateToProjects,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'Inspection Overview',
                  actionLabel: 'View All',
                  onActionTap: widget.onNavigateToProjects,
                ),
                const SizedBox(height: 12),
                FluentCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ProgressRing(
                        progress: _avgProgress,
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
                              'Assigned Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _assigned == 0
                                  ? 'No projects assigned yet.'
                                  : '$_completed of $_assigned projects completed. Average progress ${(_avgProgress * 100).round()}%.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _avgProgress,
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
                SectionHeader(
                  title: 'Recent Notifications',
                  actionLabel: 'View All',
                  onActionTap: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.engineerNotifications);
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
