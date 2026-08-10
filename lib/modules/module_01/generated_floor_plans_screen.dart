import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class GeneratedFloorPlansScreen extends StatefulWidget {
  const GeneratedFloorPlansScreen({super.key});

  @override
  State<GeneratedFloorPlansScreen> createState() =>
      _GeneratedFloorPlansScreenState();
}

class _GeneratedFloorPlansScreenState extends State<GeneratedFloorPlansScreen> {
  int _selectedPlan = 0;

  static const _plans = [
    (
      name: 'Plan A — Compact Layout',
      area: '1,850 sq.ft',
      rooms: ['Bed 1', 'Bed 2', 'Bed 3', 'Bath', 'Kitchen', 'Living'],
      badge: 'Recommended',
    ),
    (
      name: 'Plan B — Open Living',
      area: '1,920 sq.ft',
      rooms: ['Master', 'Bed 2', 'Bed 3', 'Bath ×2', 'Kitchen', 'Lounge'],
      badge: 'Spacious',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[2];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'AI-generated floor plans based on your plot size and room requirements.',
      bottomLabel: 'Continue to Elevation Design',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Floor Plans',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a floor plan to proceed with elevation design.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_plans.length, (i) {
            final plan = _plans[i];
            final selected = _selectedPlan == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: FluentCard(
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: selected ? 2 : 1,
                  ),
                  color: selected
                      ? AppColors.primaryFixed.withValues(alpha: 0.12)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plan.badge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FloorPlanPreview(rooms: plan.rooms),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.square_foot_outlined,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            plan.area,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: plan.rooms.map((r) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  r,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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

class _FloorPlanPreview extends StatelessWidget {
  const _FloorPlanPreview({required this.rooms});

  final List<String> rooms;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: CustomPaint(
        painter: _FloorPlanPainter(rooms.length),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '2D Preview',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.outline,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  _FloorPlanPainter(this.roomCount);

  final int roomCount;

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = AppColors.primaryFixed.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, wall);

    final cols = roomCount.clamp(2, 4);
    final cellW = (size.width - 16) / cols;
    for (var i = 1; i < cols; i++) {
      canvas.drawLine(
        Offset(8 + cellW * i, 8),
        Offset(8 + cellW * i, size.height - 16),
        wall,
      );
    }
    canvas.drawLine(
      Offset(8, size.height / 2),
      Offset(size.width - 8, size.height / 2),
      wall,
    );
  }

  @override
  bool shouldRepaint(covariant _FloorPlanPainter oldDelegate) =>
      oldDelegate.roomCount != roomCount;
}
