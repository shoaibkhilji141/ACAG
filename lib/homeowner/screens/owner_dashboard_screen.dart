import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
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
  Map<String, dynamic>? _profile;
  List<NotificationModel> _notifications = const [];
  int _unread = 0;
  int _visitCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_onNotify);
    _bootstrap();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_onNotify);
    super.dispose();
  }

  void _onNotify() {
    _loadNotificationsOnly();
  }

  Future<void> _bootstrap() async {
    final cachedList = ProjectService.cachedOwnerProjects;
    final cachedProject =
        (cachedList != null && cachedList.isNotEmpty) ? cachedList.first : null;
    final cachedProfile = AuthService.cachedProfile;
    final cachedNotes = NotificationService.cachedList;
    if (cachedProject != null || cachedProfile != null) {
      setState(() {
        _project = cachedProject;
        _profile = cachedProfile;
        _notifications = cachedNotes?.take(5).toList() ?? const [];
        _unread = NotificationService.cachedUnread ?? 0;
        _loading = false;
      });
    }
    await _reload();
  }

  Future<void> _loadNotificationsOnly() async {
    final notes = await NotificationService.listMine(limit: 5);
    final unread = await NotificationService.unreadCount();
    if (!mounted) return;
    setState(() {
      _notifications = notes;
      _unread = unread;
    });
  }

  Future<void> _reload() async {
    final profile = await AuthService.currentProfile();
    final project = await ProjectService.primaryOwnerProject();
    final notes = await NotificationService.listMine(limit: 5);
    final unread = await NotificationService.unreadCount();
    var visits = 0;
    if (project != null) {
      visits = await ProjectService.visitCountForProject(project.id);
      // Warm details cache for project tab.
      unawaitedPrefetch(project.id);
    }
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _project = project;
      _notifications = notes;
      _unread = unread;
      _visitCount = visits;
      _loading = false;
    });
  }

  void unawaitedPrefetch(String code) {
    ProjectService.prefetchDetails(code);
  }

  String get _ownerName =>
      _profile?['full_name'] as String? ?? 'Home Owner';

  String get _location =>
      _profile?['location_text'] as String? ??
      _profile?['city'] as String? ??
      '—';

  String get _initials {
    final parts = _ownerName.split(' ').where((p) => p.isNotEmpty).take(2);
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = _project;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        showAvatar: true,
        avatarInitials: _initials.isEmpty ? 'HO' : _initials,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.pushNamed(context, AppRoutes.ownerNotifications);
        },
        onAvatarTap: () {},
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
              Text(
                'Welcome, $_ownerName',
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
                  Expanded(
                    child: Text(
                      _location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading && project == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (project == null)
                FluentCard(
                  child: Text(
                    'No house project is linked to this account yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                _ProjectStatusHero(
                  project: project,
                  onViewDetails: () {
                    Navigator.pushNamed(context, AppRoutes.ownerProject);
                  },
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Quick Info'),
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
                      label: 'Visits Done',
                      value: '$_visitCount',
                    ),
                    _QuickInfoTile(
                      icon: Icons.event_outlined,
                      label: 'Next Visit',
                      value: project.nextInspection,
                    ),
                    _QuickInfoTile(
                      icon: Icons.engineering_outlined,
                      label: 'Engineer',
                      value: project.engineerName,
                    ),
                    _QuickInfoTile(
                      icon: Icons.construction_outlined,
                      label: 'Status',
                      value: '${project.statusLabel} / ${project.phase}',
                      compact: true,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recent Updates',
                actionLabel: 'View All',
                onActionTap: () {
                  Navigator.pushNamed(context, AppRoutes.ownerNotifications);
                },
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 24),
              const SectionHeader(title: 'Shortcuts'),
              const SizedBox(height: 12),
              _ShortcutRow(
                items: const [
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
      ),
    );
  }
}

class _ProjectStatusHero extends StatelessWidget {
  const _ProjectStatusHero({
    required this.project,
    required this.onViewDetails,
  });

  final ProjectModel project;
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
                      project.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.id,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                progress: project.progress,
                size: 88,
                strokeWidth: 8,
                progressColor: AppColors.onPrimary,
                trackColor: AppColors.onPrimary.withValues(alpha: 0.25),
                centerText: '${(project.progress * 100).round()}%',
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
