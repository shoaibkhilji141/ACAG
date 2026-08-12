import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/share_download_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class CompletionCertificateScreen extends StatelessWidget {
  const CompletionCertificateScreen({super.key});

  Future<void> _downloadAndFinish(BuildContext context) async {
    final screen = stitchScreens[14];
    final project = projectFromRoute(context);
    const completionDate = '10 August 2026';

    final content = '''
GOVERNMENT OF PUNJAB — ACAG
Completion Certificate
----------------------
Project ID: ${project.id}
Title: ${project.title}
Owner: ${project.ownerName}
Address: ${project.address}, ${project.city}
Engineer: ${project.engineerName}
Completion Date: $completionDate
Consultancy: The Urban Unit
'''.trim();

    await ShareDownloadService.downloadTextFile(
      fileName: '${project.id}_completion_certificate.txt',
      content: content,
    );

    if (!context.mounted) return;
    navigateStitchNext(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[14];
    final theme = Theme.of(context);
    final project = projectFromRoute(context);
    const completionDate = '10 August 2026';

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Official completion certificate issued by ACAG — Government of Punjab.',
      bottomLabel: 'Download Certificate',
      onBottomPressed: () => _downloadAndFinish(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Certificate',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This certificate confirms successful completion of construction works.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FluentCard(
            padding: const EdgeInsets.all(0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          color: AppColors.onPrimaryContainer,
                          size: 32,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'GOVERNMENT OF PUNJAB',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Apni Chhat Apna Ghar (ACAG)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'CERTIFICATE OF COMPLETION',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is to certify that the construction project listed below '
                          'has been completed in accordance with approved plans and '
                          'Punjab Building Authority regulations.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.outlineVariant),
                        const SizedBox(height: 16),
                        _CertificateField(
                          label: 'Owner Name',
                          value: project.ownerName,
                        ),
                        _CertificateField(
                          label: 'Plot / Address',
                          value: '${project.address}, ${project.city}',
                        ),
                        _CertificateField(
                          label: 'Project ID',
                          value: project.id,
                        ),
                        _CertificateField(
                          label: 'Project Title',
                          value: project.title,
                        ),
                        _CertificateField(
                          label: 'Completion Date',
                          value: completionDate,
                          highlight: true,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 1,
                                  color: AppColors.outline,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Engineer',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  project.engineerName,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'ACAG\nSEAL',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FluentCard(
            child: Row(
              children: [
                Icon(Icons.verified_user, color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Certificate digitally signed and registered with The Urban Unit.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateField extends StatelessWidget {
  const _CertificateField({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
