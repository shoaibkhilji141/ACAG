import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class SoilAnalysisDetailsScreen extends StatefulWidget {
  const SoilAnalysisDetailsScreen({super.key});

  @override
  State<SoilAnalysisDetailsScreen> createState() =>
      _SoilAnalysisDetailsScreenState();
}

class _SoilAnalysisDetailsScreenState extends State<SoilAnalysisDetailsScreen> {
  int _soilTypeIndex = 0;
  bool _hasEvidencePhoto = false;
  final _bearingController = TextEditingController(text: '180');
  final _waterTableController = TextEditingController(text: '2.5');

  static const _soilTypes = [
    ('Clayey Soil', 'High cohesion, moderate bearing'),
    ('Sandy Soil', 'Good drainage, requires compaction'),
    ('Loamy Soil', 'Balanced — ideal for residential'),
    ('Rocky Substrate', 'Excellent bearing capacity'),
  ];

  @override
  void dispose() {
    _bearingController.dispose();
    _waterTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[5];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Enter soil test results for foundation design and depth recommendations.',
      bottomLabel: 'Generate Foundation Drawing',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soil Analysis Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on borehole test at plot centre (NBC Pakistan guidelines).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Soil Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_soilTypes.length, (i) {
            final soil = _soilTypes[i];
            final selected = _soilTypeIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _soilTypeIndex = i),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryFixed.withValues(alpha: 0.2)
                        : AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        color: selected ? AppColors.primary : AppColors.outline,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              soil.$1,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              soil.$2,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SoilField(
                  label: 'Bearing Capacity',
                  controller: _bearingController,
                  suffix: 'kN/m²',
                  icon: Icons.compress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SoilField(
                  label: 'Water Table Depth',
                  controller: _waterTableController,
                  suffix: 'm',
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FluentCard(
            color: AppColors.info.withValues(alpha: 0.08),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science_outlined, color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recommended foundation: ${_soilTypeIndex <= 1 ? 'Raft' : 'Strip'} '
                    'footing at ${(double.tryParse(_waterTableController.text) ?? 2.5) + 1.2}m depth.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SiteEvidencePhotoCard(
            hasPhoto: _hasEvidencePhoto,
            onTap: () => setState(() => _hasEvidencePhoto = true),
          ),
        ],
      ),
    );
  }
}

class _SiteEvidencePhotoCard extends StatelessWidget {
  const _SiteEvidencePhotoCard({
    required this.hasPhoto,
    required this.onTap,
  });

  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FluentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Evidence Photo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: AppColors.outlineVariant.withValues(alpha: 0.8),
                  radius: 12,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        hasPhoto
                            ? Icons.check_circle_outline
                            : Icons.photo_camera_outlined,
                        size: 28,
                        color: hasPhoto
                            ? AppColors.primary
                            : AppColors.outline,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hasPhoto
                            ? 'Site evidence photo added'
                            : 'Upload site evidence photo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Photo of exposed soil at excavation',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is evidence documentation, not the basis of classification.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.outline,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLength = 6.0;
    const dashGap = 4.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _SoilField extends StatelessWidget {
  const _SoilField({
    required this.label,
    required this.controller,
    required this.suffix,
    required this.icon,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLowest,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
