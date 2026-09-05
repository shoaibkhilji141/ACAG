import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../theme/app_theme.dart';

class OwnerVisitsScreen extends StatefulWidget {
  const OwnerVisitsScreen({super.key});

  @override
  State<OwnerVisitsScreen> createState() => _OwnerVisitsScreenState();
}

class _OwnerVisitsScreenState extends State<OwnerVisitsScreen> {
  ProjectModel? _project;
  List<Map<String, dynamic>> _visits = [];
  bool _loading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_badge);
    _badge();
    _load();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_badge);
    super.dispose();
  }

  Future<void> _badge() async {
    final n = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = n);
  }

  Future<void> _load({bool force = false}) async {
    final project = await ProjectService.primaryOwnerProject();
    if (project == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _project = null;
          _visits = [];
        });
      }
      return;
    }

    if (!force) {
      final cached = ProjectService.getCachedVisits(project.id) ??
          ProjectService.getCachedBundle(project.id)?.visits;
      if (cached != null) {
        setState(() {
          _project = project;
          _visits = cached;
          _loading = false;
        });
      }
    }

    final rows = await ProjectService.listEngineerVisits(
      project.id,
      forceRefresh: force,
    );
    if (!mounted) return;
    setState(() {
      _project = project;
      _visits = rows;
      _loading = false;
    });
  }

  String _engineerName(Map<String, dynamic> visit) {
    final eng = visit['engineer'];
    if (eng is Map && eng['full_name'] != null) {
      return eng['full_name'].toString();
    }
    return _project?.engineerName ?? 'Assigned Engineer';
  }

  String _fmt(String? raw, {bool withTime = true}) {
    if (raw == null) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '—';
    return withTime
        ? DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal())
        : DateFormat('dd MMM yyyy').format(parsed.toLocal());
  }

  void _openVisit(Map<String, dynamic> visit) {
    final theme = Theme.of(context);
    final purpose = (visit['trigger_source'] as String?) == 'image_upload'
        ? 'Site photo / inspection visit'
        : (visit['trigger_source'] as String? ?? 'Site visit');
    final notes = (visit['notes'] as String?)?.trim() ?? '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Engineer Visit',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _row('Assigned engineer', _engineerName(visit)),
              _row('Visit date & time', _fmt(visit['visited_at'] as String?)),
              _row('Visit purpose', purpose),
              _row('Visit status', 'Completed'),
              _row(
                'Engineer remarks',
                notes.isEmpty ? '—' : notes,
              ),
              _row('Issues identified', '—'),
              _row(
                'Next visit date',
                _fmt(visit['next_visit_at'] as String?, withTime: false),
              ),
              _row('Submitted photographs', 'See Site Photos'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String k, String v) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Engineer Visits',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _visits.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.engineering_outlined,
                        message: _project == null
                            ? 'No project linked.'
                            : 'No engineer visits recorded yet.',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _visits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final visit = _visits[index];
                      final engineer = _engineerName(visit);
                      final when = _fmt(visit['visited_at'] as String?);
                      final next = _fmt(
                        visit['next_visit_at'] as String?,
                        withTime: false,
                      );

                      return FluentCard(
                        onTap: () => _openVisit(visit),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.engineering_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    engineer,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    when,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Next: $next',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Completed',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.outline,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
