import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Decorative gradient header with construction pattern for hero sections.
class ConstructionHero extends StatelessWidget {
  const ConstructionHero({
    super.key,
    this.height = 200,
    this.title,
    this.subtitle,
    this.child,
    this.showOrgLine = true,
  });

  final double height;
  final String? title;
  final String? subtitle;
  final Widget? child;
  final bool showOrgLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryContainer,
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: _ConstructionPatternPainter(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOrgLine) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppConstants.orgLine,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (title != null)
                    Text(
                      title!,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                  if (child != null) ...[
                    const Spacer(),
                    child!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstructionPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (var x = 0.0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (var x = spacing / 2; x < size.width; x += spacing * 2) {
      for (var y = spacing / 2; y < size.height; y += spacing * 2) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }

    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _drawCrane(canvas, Offset(size.width * 0.78, size.height * 0.35), iconPaint);
    _drawBuilding(canvas, Offset(size.width * 0.15, size.height * 0.55), iconPaint);
  }

  void _drawCrane(Canvas canvas, Offset origin, Paint paint) {
    canvas.drawLine(origin, origin + const Offset(0, -40), paint);
    canvas.drawLine(origin + const Offset(0, -40), origin + const Offset(50, -40), paint);
    canvas.drawLine(origin + const Offset(50, -40), origin + const Offset(50, -20), paint);
    canvas.drawLine(origin, origin + const Offset(-15, 15), paint);
    canvas.drawLine(origin, origin + const Offset(15, 15), paint);
  }

  void _drawBuilding(Canvas canvas, Offset origin, Paint paint) {
    const w = 36.0;
    const h = 48.0;
    final rect = Rect.fromLTWH(origin.dx, origin.dy - h, w, h);
    canvas.drawRect(rect, paint);

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 2; col++) {
        final cx = origin.dx + 8 + col * 14;
        final cy = origin.dy - h + 10 + row * 14;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy), width: 8, height: 8),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rounded bottom clip variant for screens that overlap content on the hero.
class ConstructionHeroClip extends StatelessWidget {
  const ConstructionHeroClip({
    super.key,
    required this.child,
    this.heroHeight = 180,
    this.borderRadius = 24,
  });

  final Widget child;
  final double heroHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
