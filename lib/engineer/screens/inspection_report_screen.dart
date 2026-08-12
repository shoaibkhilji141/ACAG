import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/share_download_service.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class InspectionReportScreen extends StatelessWidget {
  const InspectionReportScreen({super.key});

  ({ProjectModel project, ReportItem report}) _resolveArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ReportItem) {
      return (project: MockData.primaryProject, report: args);
    }
    if (args is ProjectModel) {
      return (project: args, report: MockData.reports.first);
    }
    return (project: MockData.primaryProject, report: MockData.reports.first);
  }

  String _reportText(ProjectModel project, ReportItem report) {
    return '''
ACAG Inspection Report
----------------------
Report: ${report.title}
Code: ${report.id}
Date: ${report.date}
Result: ${report.result}
Score: ${report.score}
Project: ${project.id} — ${project.title}
Owner: ${project.ownerName}
Address: ${project.address}, ${project.city}
Engineer: ${project.engineerName}
'''.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:project, :report) = _resolveArgs(context);
    final findings = MockData.aiChecks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inspection Report'),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ShareDownloadService.sharePlainText(
                title: report.title,
                body: _reportText(project, report),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              ShareDownloadService.downloadTextFile(
                fileName: '${report.id}_report.txt',
                content: _reportText(project, report),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${project.title} · ${report.date}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${report.score}%',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Score',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Result: ${report.result}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Findings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FluentCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < findings.length; i++)
                    _FindingRow(
                      title: findings[i].$1,
                      passed: findings[i].$2,
                      detail: findings[i].$3,
                      showDivider: i < findings.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rework request sent to owner (mock)'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Request Rework'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${report.title} approved (mock)'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == AppRoutes.engineerShell,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FindingRow extends StatelessWidget {
  const _FindingRow({
    required this.title,
    required this.passed,
    required this.detail,
    required this.showDivider,
  });

  final String title;
  final bool passed;
  final String detail;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                passed ? Icons.check : Icons.close,
                size: 20,
                color: passed ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 12),
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
                      detail,
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
        if (showDivider)
          Divider(
            height: 1,
            indent: 48,
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
