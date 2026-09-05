import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_modules.dart';
import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/owner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/module_certificate.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../theme/app_theme.dart';

class OwnerReportsScreen extends StatefulWidget {
  const OwnerReportsScreen({super.key});

  @override
  State<OwnerReportsScreen> createState() => _OwnerReportsScreenState();
}

class _OwnerReportsScreenState extends State<OwnerReportsScreen> {
  int _tab = 0;
  List<ModuleReportItem> _reports = const [];
  List<Map<String, dynamic>> _documents = const [];
  bool _loading = true;
  int _unread = 0;
  String? _projectId;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_reloadBadge);
    _reload();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_reloadBadge);
    super.dispose();
  }

  Future<void> _reloadBadge() async {
    final count = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final project = await ProjectService.primaryOwnerProject();
    final reports = await ProjectService.listOwnerModuleReports();
    final docs = project == null
        ? <Map<String, dynamic>>[]
        : await OwnerService.listDocuments(project.id);
    final count = await NotificationService.unreadCount();
    if (!mounted) return;
    setState(() {
      _projectId = project?.id;
      _reports = reports;
      _documents = docs;
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

  Color _docStatusColor(String status) {
    return switch (status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      'submitted' => AppColors.primary,
      _ => AppColors.warning,
    };
  }

  String _docStatusLabel(String status) {
    return switch (status) {
      'approved' => 'Approved',
      'rejected' => 'Rejected',
      'submitted' => 'Submitted',
      'pending' => 'Pending',
      _ => status,
    };
  }

  String _docTypeIconLabel(String type) {
    return switch (type) {
      'cnic' => 'CNIC',
      'property' => 'Property',
      'plan' => 'Plan',
      'noc' => 'NOC',
      'loan' => 'Loan/Grant',
      'engineer_report' => 'Eng. Report',
      'completion_cert' => 'Certificate',
      _ => type,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Reports & Documents',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Module Reports'),
                    selected: _tab == 0,
                    onSelected: (_) => setState(() => _tab = 0),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _tab == 0
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Documents'),
                    selected: _tab == 1,
                    onSelected: (_) => setState(() => _tab = 1),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: _tab == 1
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_projectId != null) {
                  OwnerService.invalidateCaches(_projectId);
                }
                await _reload();
              },
              child: _loading
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : _tab == 0
                      ? _buildReports(theme)
                      : _buildDocuments(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReports(ThemeData theme) {
    if (_reports.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 80),
          EmptyPlaceholder(
            icon: Icons.description_outlined,
            message:
                'Module reports will appear here as construction modules are completed.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = _reports[index];
        final title = ModuleCertificate.titleForModule(report.moduleNo);
        final date =
            DateFormat('dd MMM yyyy').format(report.completedAt.toLocal());
        final moduleInfo = report.moduleNo >= 1 &&
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
                  color: (moduleInfo?.accentColor ?? AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  moduleInfo?.icon ?? Icons.description_outlined,
                  color: moduleInfo?.accentColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Module ${report.moduleNo.toString().padLeft(2, '0')} — $title',
                      style: theme.textTheme.titleMedium?.copyWith(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
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
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocuments(ThemeData theme) {
    if (_documents.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 80),
          EmptyPlaceholder(
            icon: Icons.folder_outlined,
            message: 'No documents on file yet for this house project.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _documents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = _documents[index];
        final status = (doc['status'] as String?) ?? 'pending';
        final type = (doc['doc_type'] as String?) ?? 'other';
        final notes = (doc['notes'] as String?)?.trim() ?? '';

        return FluentCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _docStatusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  color: _docStatusColor(status),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title'] as String? ?? 'Document',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _docTypeIconLabel(type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _docStatusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _docStatusLabel(status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _docStatusColor(status),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
