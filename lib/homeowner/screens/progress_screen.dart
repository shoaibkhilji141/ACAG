import 'package:flutter/material.dart';

import '../../shared/models/models.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = MockData.primaryProject;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Construction Progress',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            FluentCard(
              child: Row(
                children: [
                  ProgressRing(
                    progress: project.progress,
                    size: 100,
                    strokeWidth: 9,
                    centerSubtext: 'Complete',
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phase: ${project.phase}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(project.progress * 100).round()}% of stages completed',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Stage Timeline'),
            const SizedBox(height: 12),
            FluentCard(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < MockData.stages.length; i++)
                    _StageTimelineRow(
                      stage: MockData.stages[i],
                      isFirst: i == 0,
                      isLast: i == MockData.stages.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageTimelineRow extends StatelessWidget {
  const _StageTimelineRow({
    required this.stage,
    required this.isFirst,
    required this.isLast,
  });

  final ProgressStage stage;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: stage.completed || _previousCompleted()
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: stage.completed
                        ? AppColors.primaryContainer
                        : AppColors.surfaceLowest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stage.completed
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant,
                      width: 2,
                    ),
                    boxShadow: stage.completed ? AppColors.softShadow : null,
                  ),
                  child: Icon(
                    stage.completed ? Icons.check : Icons.schedule_outlined,
                    size: 14,
                    color: stage.completed
                        ? AppColors.onPrimary
                        : AppColors.outline,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: stage.completed
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stage.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: stage.completed
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: stage.completed
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        stage.date,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  if (stage.note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      stage.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _previousCompleted() {
    final index = MockData.stages.indexOf(stage);
    if (index <= 0) return false;
    return MockData.stages[index - 1].completed;
  }
}
