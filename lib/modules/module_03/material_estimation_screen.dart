import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class MaterialEstimationScreen extends StatefulWidget {
  const MaterialEstimationScreen({super.key});

  @override
  State<MaterialEstimationScreen> createState() =>
      _MaterialEstimationScreenState();
}

class _MaterialEstimationScreenState extends State<MaterialEstimationScreen> {
  bool _loading = true;
  bool _saving = false;
  double _bricks = 0;
  double _cement = 0;
  double _steel = 0;
  double _sand = 0;
  double? _plotArea;
  int? _stories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    try {
      final saved = await ProjectService.getMaterialEstimate(project.id);
      final plot = await ProjectService.getPlotDimensions(project.id);
      final stories = await ProjectService.getStories(project.id);
      _plotArea = (plot?['total_area'] as num?)?.toDouble();
      _stories = (stories?['stories_count'] as num?)?.toInt();

      if (saved != null) {
        _bricks = (saved['bricks_qty'] as num?)?.toDouble() ?? 0;
        _cement = (saved['cement_bags'] as num?)?.toDouble() ?? 0;
        _steel = (saved['steel_tons'] as num?)?.toDouble() ?? 0;
        _sand = (saved['sand_units'] as num?)?.toDouble() ?? 0;
      } else if (_plotArea != null && _plotArea! > 0) {
        _computeFromPlot(_plotArea!, _stories ?? 1);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _computeFromPlot(double area, int stories) {
    final factor = stories.clamp(1, 5).toDouble();
    _bricks = (area * 8.1 * factor).roundToDouble();
    _cement = (area * 0.18 * factor).roundToDouble();
    _steel = double.parse((area * 0.0009 * factor).toStringAsFixed(1));
    _sand = (area * 1.35 * factor).roundToDouble();
  }

  String _fmt(num n) {
    if (n == n.roundToDouble()) {
      return n.round().toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return n.toStringAsFixed(1);
  }

  Future<void> _save() async {
    final screen = stitchScreens[8];
    final project = projectFromRoute(context);
    if (_bricks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save plot dimensions & stories first to estimate materials'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ProjectService.saveMaterialEstimate(
        projectCodeOrId: project.id,
        bricksQty: _bricks,
        cementBags: _cement,
        steelTons: _steel,
        sandUnits: _sand,
        basedOnPlotArea: _plotArea,
        basedOnStories: _stories,
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
    final screen = stitchScreens[8];
    final theme = Theme.of(context);

    final materials = [
      (name: 'Bricks', unit: 'Nos.', qty: _fmt(_bricks)),
      (name: 'Cement', unit: 'Bags', qty: _fmt(_cement)),
      (name: 'Steel (Sarya)', unit: 'Tons', qty: _fmt(_steel)),
      (name: 'Sand (Ravi)', unit: 'Cft', qty: _fmt(_sand)),
    ];

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Estimated material quantities for your approved structural design.',
      bottomLabel: _saving ? 'Saving…' : 'Save Material Estimate',
      onBottomPressed: (_loading || _saving) ? null : _save,
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material Estimation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _plotArea == null
                      ? 'Complete Module 1 & 2 first for accurate estimates.'
                      : 'Based on plot area ${_fmt(_plotArea!)} sq.ft'
                          '${_stories != null ? ', $_stories stor${_stories == 1 ? 'y' : 'ies'}' : ''}.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FluentCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Material',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Qty',
                                textAlign: TextAlign.end,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(materials.length, (i) {
                        final m = materials[i];
                        final isLast = i == materials.length - 1;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.name,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      m.unit,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  m.qty,
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
