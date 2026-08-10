import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class StructuralFrameTypeScreen extends StatefulWidget {
  const StructuralFrameTypeScreen({super.key});

  @override
  State<StructuralFrameTypeScreen> createState() =>
      _StructuralFrameTypeScreenState();
}

class _StructuralFrameTypeScreenState extends State<StructuralFrameTypeScreen> {
  int _frameType = 0;

  static const _options = [
    (
      title: 'RCC Frame Structure',
      subtitle: 'Reinforced concrete columns & beams',
      pros: ['Earthquake resistant', 'Flexible layout', 'Multi-story capable'],
      icon: Icons.view_column_outlined,
      recommended: true,
    ),
    (
      title: 'Load Bearing Wall',
      subtitle: 'Brick/block walls carry vertical loads',
      pros: ['Lower cost', 'Faster construction', 'Good for 1–2 stories'],
      icon: Icons.grid_view_outlined,
      recommended: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[7];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Choose the structural system for your building based on stories and budget.',
      bottomLabel: 'Confirm Structural Frame',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Structural Frame Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'RCC frame is recommended for double/triple story buildings in seismic zones.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            final selected = _frameType == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _frameType = i),
                child: FluentCard(
                  color: selected
                      ? AppColors.primaryFixed.withValues(alpha: 0.15)
                      : null,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: selected ? 2 : 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(opt.icon, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        opt.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (opt.recommended)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Recommended',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  opt.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FrameDiagram(type: i),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: opt.pros.map((p) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  p,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FrameDiagram extends StatelessWidget {
  const _FrameDiagram({required this.type});

  final int type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _FrameDiagramPainter(isRcc: type == 0),
      ),
    );
  }
}

class _FrameDiagramPainter extends CustomPainter {
  _FrameDiagramPainter({required this.isRcc});

  final bool isRcc;

  @override
  void paint(Canvas canvas, Size size) {
    if (isRcc) {
      final col = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4;
      for (final x in [0.2, 0.5, 0.8]) {
        canvas.drawLine(
          Offset(size.width * x, size.height * 0.85),
          Offset(size.width * x, size.height * 0.15),
          col,
        );
      }
      final beam = Paint()
        ..color = AppColors.secondary
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset(size.width * 0.15, size.height * 0.35),
        Offset(size.width * 0.85, size.height * 0.35),
        beam,
      );
      canvas.drawLine(
        Offset(size.width * 0.15, size.height * 0.65),
        Offset(size.width * 0.85, size.height * 0.65),
        beam,
      );
    } else {
      final wall = Paint()..color = AppColors.outline.withValues(alpha: 0.7);
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.25, size.height * 0.65),
        wall,
      );
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.2, size.width * 0.25, size.height * 0.65),
        wall,
      );
      final slab = Paint()..color = AppColors.primary.withValues(alpha: 0.5);
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.15, size.width * 0.9, 8),
        slab,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FrameDiagramPainter oldDelegate) =>
      oldDelegate.isRcc != isRcc;
}
