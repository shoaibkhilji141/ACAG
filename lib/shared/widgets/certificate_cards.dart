import 'package:flutter/material.dart';

import '../models/models.dart';
import '../../theme/app_theme.dart';
import 'certificate_widgets.dart';

class ModuleCompletionCertificateCard extends StatelessWidget {
  const ModuleCompletionCertificateCard({
    super.key,
    required this.project,
    required this.moduleNo,
    required this.moduleTitle,
    required this.completionDate,
  });

  final ProjectModel project;
  final int moduleNo;
  final String moduleTitle;
  final String completionDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CertificateHeader(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'MODULE COMPLETION CERTIFICATE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is to certify that the following construction module '
                  'has been completed successfully under the ACAG validation programme.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.outlineVariant),
                const SizedBox(height: 16),
                CertificateField(
                  label: 'Module',
                  value:
                      'Module ${moduleNo.toString().padLeft(2, '0')} — $moduleTitle',
                  highlight: true,
                ),
                CertificateField(
                  label: 'Home Owner',
                  value: project.ownerName,
                ),
                if (project.ownerPhone != null &&
                    project.ownerPhone!.trim().isNotEmpty)
                  CertificateField(
                    label: 'Owner Phone',
                    value: project.ownerPhone!,
                  ),
                CertificateField(
                  label: 'Plot / Address',
                  value: '${project.address}, ${project.city}',
                ),
                CertificateField(
                  label: 'Project ID',
                  value: project.id,
                ),
                CertificateField(
                  label: 'Project Title',
                  value: project.title,
                ),
                CertificateField(
                  label: 'Completion Date',
                  value: completionDate,
                  highlight: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 1,
                          color: AppColors.outline,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Certifying Engineer',
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
    );
  }
}

class ProjectCompletionCertificateCard extends StatelessWidget {
  const ProjectCompletionCertificateCard({
    super.key,
    required this.project,
    required this.completionDate,
  });

  final ProjectModel project;
  final String completionDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CertificateHeader(),
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
                CertificateField(
                  label: 'Owner Name',
                  value: project.ownerName,
                ),
                if (project.ownerPhone != null &&
                    project.ownerPhone!.trim().isNotEmpty)
                  CertificateField(
                    label: 'Owner Phone',
                    value: project.ownerPhone!,
                  ),
                CertificateField(
                  label: 'Plot / Address',
                  value: '${project.address}, ${project.city}',
                ),
                CertificateField(
                  label: 'Project ID',
                  value: project.id,
                ),
                CertificateField(
                  label: 'Project Title',
                  value: project.title,
                ),
                CertificateField(
                  label: 'Completion Date',
                  value: completionDate,
                  highlight: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
