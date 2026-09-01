import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/certificate_image_service.dart';
import '../../shared/utils/module_certificate.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/certificate_cards.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class CompletionCertificateScreen extends StatefulWidget {
  const CompletionCertificateScreen({super.key});

  @override
  State<CompletionCertificateScreen> createState() =>
      _CompletionCertificateScreenState();
}

class _CompletionCertificateScreenState
    extends State<CompletionCertificateScreen> {
  final _certificateKey = GlobalKey();
  bool _busy = false;

  String get _fileName {
    final project = projectFromRoute(context);
    return '${project.id}_completion_certificate';
  }

  Future<void> _runCertificateAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _shareCertificate() async {
    final project = projectFromRoute(context);

    await _runCertificateAction(
      () => CertificateImageService.shareImage(
        key: _certificateKey,
        fileName: _fileName,
        shareText:
            'ACAG completion certificate for ${project.ownerName} — ${project.id}',
      ),
      successMessage: 'Certificate image ready to share.',
    );
  }

  Future<void> _downloadCertificate() async {
    await _runCertificateAction(
      () => CertificateImageService.downloadImage(
        key: _certificateKey,
        fileName: _fileName,
      ),
      successMessage: 'Certificate image saved to your gallery.',
    );
  }

  Future<void> _finish(BuildContext context) async {
    final screen = stitchScreens[14];
    if (!context.mounted) return;
    navigateStitchNext(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[14];
    final theme = Theme.of(context);
    final project = projectFromRoute(context);
    final completionDate = ModuleCertificate.formatDate(DateTime.now());

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Official completion certificate issued by ACAG — Government of Punjab.',
      bottomLabel: _busy ? 'Please wait…' : 'Finish',
      onBottomPressed: _busy ? null : () => _finish(context),
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
          RepaintBoundary(
            key: _certificateKey,
            child: ProjectCompletionCertificateCard(
              project: project,
              completionDate: completionDate,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _shareCertificate,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _downloadCertificate,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Download'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FluentCard(
            child: Row(
              children: [
                Icon(Icons.image_outlined, color: AppColors.primary, size: 20),
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
