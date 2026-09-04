import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_modules.dart';
import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/module_certificate.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../theme/app_theme.dart';

class EngineerReportsTab extends StatefulWidget {
  const EngineerReportsTab({super.key});

  @override
  State<EngineerReportsTab> createState() => _EngineerReportsTabState();
}

class _EngineerReportsTabState extends State<EngineerReportsTab> {
  List<ModuleReportItem> _reports = const [];
  bool _loading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    ProjectService.moduleCompletionVersion.addListener(_reload);
    NotificationService.version.addListener(_reloadBadge);
    _reload();
  }

  @override
  void dispose() {
    ProjectService.moduleCompletionVersion.removeListener(_reload);
    NotificationService.version.removeListener(_reloadBadge);
    super.dispose();
  }

  Future<void> _reloadBadge() async {
    final count = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final reports = await ProjectService.listModuleReports();
    final count = await NotificationService.unreadCount();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _unread = count;
      _loading = false;
    });
  }

  Future<void> _openReport(ModuleReportItem report) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.moduleCompletionCertificate,
      arguments: StitchRouteArgs(
        project: report.project,
        moduleNo: report.moduleNo,
        completedAt: report.completedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Reports',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.engineerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _reports.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.description_outlined,
                        message:
                            'Complete a construction module to generate a shareable report here.',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final title =
                          ModuleCertificate.titleForModule(report.moduleNo);
                      final date = DateFormat('dd MMM yyyy')
                          .format(report.completedAt.toLocal());
                      final moduleInfo =
                          report.moduleNo >= 1 &&
                                  report.moduleNo <= constructionModules.length
                              ? constructionModules[report.moduleNo - 1]
                              : null;

                      return FluentCard(
                        onTap: () => _openReport(report),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (moduleInfo?.accentColor ??
                                        AppColors.primary)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                moduleInfo?.icon ?? Icons.description_outlined,
                                color: moduleInfo?.accentColor ??
                                    AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Module ${report.moduleNo.toString().padLeft(2, '0')} — $title',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${report.project.id} · $date',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
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
                            const SizedBox(width: 8),
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
