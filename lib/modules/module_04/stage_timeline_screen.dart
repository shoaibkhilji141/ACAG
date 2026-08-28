import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_stages.dart';
import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

enum _StageStatus { done, active, pending }

class StageTimelineScreen extends StatefulWidget {
  const StageTimelineScreen({super.key});

  @override
  State<StageTimelineScreen> createState() => _StageTimelineScreenState();
}

class _StageTimelineScreenState extends State<StageTimelineScreen> {
  List<Map<String, dynamic>> _completedStages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    final cached = ProjectService.getCachedBundle(project.id);
    if (cached != null) {
      setState(() {
        _completedStages = cached.constructionStages;
        _loading = false;
      });
    } else {
      setState(() => _loading = true);
    }
    try {
      final rows = await ProjectService.getConstructionStages(project.id);
      if (!mounted) return;
      setState(() {
        _completedStages = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int get _completedCount => _completedStages.length;

  double get _progress =>
      (_completedCount / ConstructionStages.total).clamp(0.0, 1.0);

  bool get _allComplete => _completedCount >= ConstructionStages.total;

  _StageStatus _statusFor(int stageNo) {
    if (stageNo <= _completedCount) return _StageStatus.done;
    if (stageNo == _completedCount + 1 && !_allComplete) {
      return _StageStatus.active;
    }
    return _StageStatus.pending;
  }

  String _dateFor(int stageNo) {
    for (final row in _completedStages) {
      final no = (row['stage_no'] as num?)?.toInt();
      if (no != stageNo) continue;
      final raw = row['completed_at'] as String?;
      if (raw == null) return 'Completed';
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return 'Completed';
      return DateFormat('dd MMM yyyy').format(parsed);
    }
    if (stageNo == _completedCount + 1 && !_allComplete) {
      return 'Ready to upload';
    }
    return '—';
  }

  void _openUpload() {
    if (_allComplete) return;
    final project = projectFromRoute(context);
    final nextStage = _completedCount + 1;
    Navigator.of(context).pushNamed(
      AppRoutes.stitchPhotoUpload,
      arguments: StitchRouteArgs(project: project, stageNo: nextStage),
    ).then((_) {
      if (mounted) _load();
    });
  }

  void _openStageDetail(int stageNo) {
    final project = projectFromRoute(context);
    Navigator.of(context).pushNamed(
      AppRoutes.stitchStageDetail,
      arguments: StitchRouteArgs(project: project, stageNo: stageNo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[9];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Track construction progress through each build stage on site.',
      bottomLabel: _allComplete
          ? 'All Stages Complete'
          : 'Upload Progress Photos',
      onBottomPressed: _allComplete ? null : _openUpload,
      body: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
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
                  'Overall progress: ${(_progress * 100).round()}% — '
                  '$_completedCount of ${ConstructionStages.total} stages complete.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceContainer,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(ConstructionStages.total, (i) {
                  final stageNo = i + 1;
                  final isLast = i == ConstructionStages.total - 1;
                  final status = _statusFor(stageNo);
                  final isDone = status == _StageStatus.done;

                  return _StageRow(
                    name: ConstructionStages.nameFor(stageNo),
                    status: status,
                    date: _dateFor(stageNo),
                    showLine: !isLast,
                    isLast: isLast,
                    onTap: isDone ? () => _openStageDetail(stageNo) : null,
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
    this.onTap,
  });

  final String name;
  final _StageStatus status;
  final String date;
  final bool showLine;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (badgeLabel, badgeColor, badgeTextColor) = switch (status) {
      _StageStatus.done => (
          'DONE',
          AppColors.success.withValues(alpha: 0.15),
          AppColors.success
        ),
      _StageStatus.active => (
          'ACTIVE',
          AppColors.warning.withValues(alpha: 0.15),
          AppColors.warning
        ),
      _StageStatus.pending => (
          'PENDING',
          AppColors.surfaceContainer,
          AppColors.outline
        ),
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
                onTap: onTap,
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
                    if (onTap != null)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.outline,
                          size: 20,
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
