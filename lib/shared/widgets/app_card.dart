import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Fluent-style card with soft shadow, white surface, and rounded corners.
class FluentCard extends StatelessWidget {
  const FluentCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
    this.margin,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceLowest,
        borderRadius: radius,
        border: border ??
            Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}
