import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class NumberOfStoriesScreen extends StatefulWidget {
  const NumberOfStoriesScreen({super.key});

  @override
  State<NumberOfStoriesScreen> createState() => _NumberOfStoriesScreenState();
}

class _NumberOfStoriesScreenState extends State<NumberOfStoriesScreen> {
  int? _stories;
  bool _loading = true;
  bool _saving = false;

  static const _options = [
    (count: 1, label: 'Single Story', desc: 'Ground floor only — ideal for 5–10 marla plots'),
    (count: 2, label: 'Double Story', desc: 'Ground + first floor — most common in Punjab'),
    (count: 3, label: 'Triple Story', desc: 'Ground + two upper floors — larger plots'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    try {
      final row = await ProjectService.getStories(project.id);
      if (!mounted) return;
      if (row != null) {
        _stories = (row['stories_count'] as num?)?.toInt();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continue() async {
    final screen = stitchScreens[4];
    final project = projectFromRoute(context);
    if (_stories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select number of stories')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ProjectService.saveStories(
        projectCodeOrId: project.id,
        storiesCount: _stories!,
      );
      if (!mounted) return;
      await navigateStitchNext(context, screen);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[4];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Select the number of stories for structural and foundation calculations.',
      bottomLabel: _saving ? 'Saving…' : 'Continue to Soil Analysis',
      onBottomPressed: (_loading || _saving) ? null : _continue,
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of Stories',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This affects foundation depth, column sizing, and load calculations.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final count = i + 1;
              final selected = _stories == count;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _stories = count),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.outlineVariant.withValues(alpha: 0.6),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected ? AppColors.softShadow : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$count',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? AppColors.onPrimary
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            count == 1 ? 'Story' : 'Stories',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: selected
                                  ? AppColors.onPrimary.withValues(alpha: 0.9)
                                  : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ..._options.map((opt) {
            final selected = _stories == opt.count;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FluentCard(
                color: selected
                    ? AppColors.primaryFixed.withValues(alpha: 0.15)
                    : null,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: selected ? 2 : 1,
                ),
                onTap: () => setState(() => _stories = opt.count),
                child: Row(
                  children: [
                    _StoryStackIcon(floors: opt.count, selected: selected),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            opt.desc,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle, color: AppColors.primary),
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

class _StoryStackIcon extends StatelessWidget {
  const _StoryStackIcon({required this.floors, required this.selected});

  final int floors;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(floors, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            height: 10,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.2 + i * 0.15)
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline,
                width: 1,
              ),
            ),
          );
        }),
      ),
    );
  }
}
