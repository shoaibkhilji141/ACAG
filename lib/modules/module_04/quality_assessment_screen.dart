import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class QualityAssessmentScreen extends StatefulWidget {
  const QualityAssessmentScreen({super.key});

  @override
  State<QualityAssessmentScreen> createState() =>
      _QualityAssessmentScreenState();
}

class _QualityAssessmentScreenState extends State<QualityAssessmentScreen> {
  final _checklist = [
    (label: 'Foundation level & alignment', passed: true),
    (label: 'Column verticality (plumb check)', passed: true),
    (label: 'Brick bond pattern & mortar ratio', passed: false),
    (label: 'Plaster thickness & finish quality', passed: true),
    (label: 'Rebar cover & lap length', passed: true),
    (label: 'Waterproofing membrane application', passed: null),
  ];

  static const _score = 82;

  void _toggleItem(int index) {
    setState(() {
      final item = _checklist[index];
      _checklist[index] = (
        label: item.label,
        passed: item.passed == true ? false : true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[11];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'AI-assisted quality assessment based on uploaded progress photos.',
      bottomLabel: 'Complete Quality Review',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Assessment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Automated QA score with engineer verification checklist.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _ScoreRingPainter(score: _score),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_score',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'QA Score',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Good — Minor issues flagged',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Inspection Checklist',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_checklist.length, (i) {
            final item = _checklist[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FluentCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: item.passed != null ? () => _toggleItem(i) : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.passed == null)
                      _StatusChip(
                        label: 'N/A',
                        color: AppColors.surfaceContainer,
                        textColor: AppColors.outline,
                      )
                    else if (item.passed!)
                      _StatusChip(
                        label: 'PASS',
                        color: AppColors.success.withValues(alpha: 0.15),
                        textColor: AppColors.success,
                      )
                    else
                      _StatusChip(
                        label: 'FAIL',
                        color: AppColors.errorContainer,
                        textColor: AppColors.error,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.score});

  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bg = Paint()
      ..color = AppColors.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * (score / 100),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.score != score;
}
