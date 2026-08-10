import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_card.dart';

/// KPI metric card for dashboard summaries.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.filled = false,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final valueColor = filled ? AppColors.onPrimary : AppColors.onSurface;
    final labelColor = filled
        ? AppColors.onPrimary.withValues(alpha: 0.85)
        : AppColors.onSurfaceVariant;
    final iconBg = filled
        ? AppColors.onPrimary.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.08);
    final iconColor = filled ? AppColors.onPrimary : AppColors.primary;

    return FluentCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      color: filled ? AppColors.primaryContainer : AppColors.surfaceLowest,
      border: filled
          ? null
          : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
