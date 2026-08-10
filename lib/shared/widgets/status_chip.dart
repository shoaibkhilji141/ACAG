import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../models/models.dart';

/// Visual styling for a [ProjectStatus] chip.
class StatusChipStyle {
  const StatusChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;
}

/// Colored status chip for [ProjectStatus] values.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ProjectStatus status;
  final bool compact;

  static StatusChipStyle styleFor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.pending => StatusChipStyle(
          label: 'Pending',
          background: AppColors.secondaryContainer,
          foreground: AppColors.secondary,
          icon: Icons.schedule_outlined,
        ),
      ProjectStatus.inProgress => StatusChipStyle(
          label: 'In Progress',
          background: AppColors.primary.withValues(alpha: 0.1),
          foreground: AppColors.primary,
          icon: Icons.construction_outlined,
        ),
      ProjectStatus.completed => StatusChipStyle(
          label: 'Completed',
          background: AppColors.primaryFixed.withValues(alpha: 0.35),
          foreground: AppColors.primaryContainer,
          icon: Icons.check_circle_outline,
        ),
      ProjectStatus.overdue => StatusChipStyle(
          label: 'Overdue',
          background: AppColors.errorContainer,
          foreground: AppColors.error,
          icon: Icons.warning_amber_rounded,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = styleFor(status);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 12 : 14, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
