import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../services/certificate_image_service.dart';
import '../utils/module_certificate.dart';
import '../utils/project_route.dart';
import '../widgets/app_card.dart';
import '../widgets/certificate_cards.dart';
import '../widgets/primary_button.dart';
import '../widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class ModuleCompletionCertificateScreen extends StatefulWidget {
  const ModuleCompletionCertificateScreen({super.key});

  @override
  State<ModuleCompletionCertificateScreen> createState() =>
      _ModuleCompletionCertificateScreenState();
}

class _ModuleCompletionCertificateScreenState
    extends State<ModuleCompletionCertificateScreen> {
  final _certificateKey = GlobalKey();
  bool _busy = false;

  String get _fileName {
    final project = projectFromRoute(context);
    final moduleNo = moduleNoFromRoute(context) ?? 1;
    return '${project.id}_module_${moduleNo.toString().padLeft(2, '0')}_certificate';
  }

  Future<void> _runCertificateAction(
    BuildContext context,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareCertificate(BuildContext context) async {
    final project = projectFromRoute(context);
    final moduleNo = moduleNoFromRoute(context) ?? 1;
    final moduleTitle = ModuleCertificate.titleForModule(moduleNo);

    await _runCertificateAction(
      context,
      () => CertificateImageService.shareImage(
        key: _certificateKey,
        fileName: _fileName,
        shareText:
            'ACAG module completion certificate for ${project.ownerName} — $moduleTitle',
      ),
      successMessage: 'Certificate image ready to share.',
    );
  }

  Future<void> _downloadCertificate(BuildContext context) async {
    await _runCertificateAction(
      context,
      () => CertificateImageService.downloadImage(
        key: _certificateKey,
        fileName: _fileName,
      ),
      successMessage: 'Certificate image saved to your gallery.',
    );
  }

  void _returnToProject(BuildContext context) {
    popToProjectHub(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);
    final moduleNo = moduleNoFromRoute(context) ?? 1;
    final moduleTitle = ModuleCertificate.titleForModule(moduleNo);
    final completionDate = ModuleCertificate.formatDate(
      completedAtFromRoute(context) ?? DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Module Completed',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: AppColors.success,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Module Completed Successfully',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$moduleTitle has been verified and saved for ${project.id}.',
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
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    key: _certificateKey,
                    child: ModuleCompletionCertificateCard(
                      project: project,
                      moduleNo: moduleNo,
                      moduleTitle: moduleTitle,
                      completionDate: completionDate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FluentCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Share or download the colorful certificate image with '
                            '${project.ownerName}.',
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
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _shareCertificate(context),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: Text(_busy ? 'Please wait…' : 'Share'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _downloadCertificate(context),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Back to Project',
                  onPressed: _busy ? null : () => _returnToProject(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showModuleCompletionCertificate(
  BuildContext context, {
  required ProjectModel project,
  required int moduleNo,
}) {
  return Navigator.of(context).pushNamed(
    AppRoutes.moduleCompletionCertificate,
    arguments: StitchRouteArgs(project: project, moduleNo: moduleNo),
  );
}
