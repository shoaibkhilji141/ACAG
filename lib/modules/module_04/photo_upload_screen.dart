import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final _descriptionController = TextEditingController();
  bool _hasPhoto = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[10];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Document on-site progress with geo-tagged photos for QA review.',
      bottomLabel: 'Submit Progress Update',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Progress Photos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current stage: Brickwork & Plaster — GPS verification enabled.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PhotoActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  onTap: () => setState(() => _hasPhoto = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'From Gallery',
                  onTap: () => setState(() => _hasPhoto = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FluentCard(
            padding: const EdgeInsets.all(0),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _hasPhoto
                    ? AppColors.surfaceLow
                    : AppColors.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _SitePhotoPlaceholderPainter(),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS Verified',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: IconButton(
                            onPressed: () => setState(() => _hasPhoto = false),
                            icon: const Icon(Icons.close, color: AppColors.error),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 40,
                          color: AppColors.outline.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No photo selected',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Work Description',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Describe work completed today (e.g. external plaster 80% done on north wall)...',
              filled: true,
              fillColor: AppColors.surfaceLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photo Guidelines',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ensure photos are taken on-site with clear visibility. '
                        'Blurry or off-site images will be rejected by AI validation.',
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
        ],
      ),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  const _PhotoActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surfaceLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SitePhotoPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = AppColors.surfaceHigh;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.4), sky);

    final wall = Paint()..color = AppColors.outline.withValues(alpha: 0.4);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.35, size.width * 0.8, size.height * 0.55),
      wall,
    );

    final scaffold = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.15, size.height * 0.9),
      scaffold,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.3),
      Offset(size.width * 0.85, size.height * 0.9),
      scaffold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
