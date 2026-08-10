import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

enum _StageStatus { done, active, pending }

class StageTimelineScreen extends StatelessWidget {
  const StageTimelineScreen({super.key});

  static const _stages = [
    (name: 'Foundation & Plinth', status: _StageStatus.done, date: '12 Jan 2026'),
    (name: 'Structure (Columns & Beams)', status: _StageStatus.done, date: '28 Feb 2026'),
    (name: 'Brickwork & Plaster', status: _StageStatus.active, date: 'In Progress'),
    (name: 'Roof Slab & Waterproofing', status: _StageStatus.pending, date: '—'),
    (name: 'Electrical & Plumbing', status: _StageStatus.pending, date: '—'),
    (name: 'Finishing & Paint', status: _StageStatus.pending, date: '—'),
    (name: 'Final Inspection & Handover', status: _StageStatus.pending, date: '—'),
  ];

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[9];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Track construction progress through each build stage on site.',
      bottomLabel: 'Upload Progress Photos',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Construction Stage Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Overall progress: 42% — 3 of 7 stages complete.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.42,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_stages.length, (i) {
            final stage = _stages[i];
            final isLast = i == _stages.length - 1;
            return _StageRow(
              name: stage.name,
              status: stage.status,
              date: stage.date,
              showLine: !isLast,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.name,
    required this.status,
    required this.date,
    required this.showLine,
    required this.isLast,
  });

  final String name;
  final _StageStatus status;
  final String date;
  final bool showLine;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (badgeLabel, badgeColor, badgeTextColor) = switch (status) {
      _StageStatus.done => ('DONE', AppColors.success.withValues(alpha: 0.15), AppColors.success),
      _StageStatus.active => ('ACTIVE', AppColors.warning.withValues(alpha: 0.15), AppColors.warning),
      _StageStatus.pending => ('PENDING', AppColors.surfaceContainer, AppColors.outline),
    };

    final dotColor = switch (status) {
      _StageStatus.done => AppColors.success,
      _StageStatus.active => AppColors.warning,
      _StageStatus.pending => AppColors.outlineVariant,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: status == _StageStatus.active
                        ? Border.all(color: AppColors.warning, width: 3)
                        : null,
                    boxShadow: status == _StageStatus.active
                        ? [
                            BoxShadow(
                              color: AppColors.warning.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: status == _StageStatus.done
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: status == _StageStatus.done
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: FluentCard(
                padding: const EdgeInsets.all(14),
                color: status == _StageStatus.active
                    ? AppColors.primaryFixed.withValues(alpha: 0.12)
                    : null,
                border: status == _StageStatus.active
                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: badgeTextColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
