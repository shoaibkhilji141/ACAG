import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/planner_service.dart';
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
  double _crush = 0;
  double? _coveredArea;
  double? _plotArea;
  int? _stories;

  // Current market prices (PKR) — mid 2026 estimates.
  double _brickPrice = 19.0;       // per brick (Awwal)
  double _cementPrice = 1540.0;     // per 50kg bag
  double _steelPrice = 280.0;       // per kg (≈280,000/ton)
  double _sandPrice = 90.0;         // per cft (Ravi)
  double _crushPrice = 250.0;       // per cft (Sargodha)

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

      // Try to get the actual covered area from the chosen floor plan.
      _coveredArea = await _getCoveredArea(project.id);

      // Always recompute from the current covered area — old saved data may
      // have been calculated with incorrect formulas.
      final area = _coveredArea ?? (_plotArea ?? 0) * 0.67;
      if (area > 0) {
        _computeFromCoveredArea(area, _stories ?? 1);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Try to read the covered area from the cached planner result.
  Future<double?> _getCoveredArea(String projectId) async {
    final cached = PlannerService.peekResult();
    if (cached != null) {
      final plans = cached['floor_plans'] as List?;
      if (plans != null && plans.isNotEmpty) {
        // Find the selected plan, or use the first one.
        final selected = plans.cast<Map<String, dynamic>>().firstWhere(
              (p) => p['is_selected'] == true,
              orElse: () => plans.first as Map<String, dynamic>,
            );
        final area = selected['area_sqft'] as num?;
        if (area != null && area > 0) return area.toDouble();
      }
    }
    return null;
  }

  /// Material estimation using real Pakistani construction thumb rules.
  ///
  /// Source: Industry standard per-sq-ft rates for grey structure (2024-2026).
  ///   Bricks:  8.5 per sq ft of covered area
  ///   Cement:  0.50 bags per sq ft
  ///   Steel:   4.0 kg per sq ft (RCC frame, single story)
  ///   Sand:    1.40 cft per sq ft
  ///   Crush:   1.00 cft per sq ft
  void _computeFromCoveredArea(double coveredArea, int stories) {
    final factor = stories.clamp(1, 3).toDouble();
    _bricks = (coveredArea * 8.5 * factor).roundToDouble();
    _cement = (coveredArea * 0.50 * factor).roundToDouble();
    // Steel in kg, then convert to tons for display
    _steel = double.parse(
        (coveredArea * 4.0 * factor / 1000.0).toStringAsFixed(2));
    _sand = (coveredArea * 1.40 * factor).roundToDouble();
    _crush = (coveredArea * 1.00 * factor).roundToDouble();
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

  String _fmtPrice(double price) {
    if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} Lakh';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)},000';
    }
    return price.round().toString();
  }

  double get _totalCost {
    return (_bricks * _brickPrice) +
        (_cement * _cementPrice) +
        (_steel * 1000 * _steelPrice) + // _steel is in tons, price is per kg
        (_sand * _sandPrice) +
        (_crush * _crushPrice);
  }

  Future<void> _save() async {
    final screen = stitchScreens[8];
    final project = projectFromRoute(context);
    if (_bricks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Save plot dimensions & stories first to estimate materials'),
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
        crushUnits: _crush,
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

  void _showEditRatesDialog() {
    final brickCtrl = TextEditingController(text: _brickPrice.toString());
    final cementCtrl = TextEditingController(text: _cementPrice.toString());
    final steelCtrl = TextEditingController(text: _steelPrice.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Market Rates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: brickCtrl, decoration: const InputDecoration(labelText: 'Brick Rate (Rs)')),
            TextField(controller: cementCtrl, decoration: const InputDecoration(labelText: 'Cement Rate (Rs)')),
            TextField(controller: steelCtrl, decoration: const InputDecoration(labelText: 'Steel Rate (Rs/kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _brickPrice = double.tryParse(brickCtrl.text) ?? _brickPrice;
                _cementPrice = double.tryParse(cementCtrl.text) ?? _cementPrice;
                _steelPrice = double.tryParse(steelCtrl.text) ?? _steelPrice;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrancheRow(ThemeData theme, String title, String subtitle, double cost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Rs ${_fmtPrice(cost)}',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[8];
    final theme = Theme.of(context);

    final materials = [
      (
        name: 'Bricks',
        unit: 'Nos.',
        qty: _fmt(_bricks),
        cost: _bricks * _brickPrice,
        rate: 'Rs ${_brickPrice.round()}/brick'
      ),
      (
        name: 'Cement',
        unit: 'Bags (50kg)',
        qty: _fmt(_cement),
        cost: _cement * _cementPrice,
        rate: 'Rs ${_fmt(_cementPrice)}/bag'
      ),
      (
        name: 'Steel (Sarya)',
        unit: 'Tons',
        qty: _fmt(_steel),
        cost: _steel * 1000 * _steelPrice,
        rate: 'Rs ${_fmt(_steelPrice)}/kg'
      ),
      (
        name: 'Sand (Ravi)',
        unit: 'Cft',
        qty: _fmt(_sand),
        cost: _sand * _sandPrice,
        rate: 'Rs ${_sandPrice.round()}/cft'
      ),
      (
        name: 'Crush (Bajri)',
        unit: 'Cft',
        qty: _fmt(_crush),
        cost: _crush * _crushPrice,
        rate: 'Rs ${_crushPrice.round()}/cft'
      ),
    ];

    final areaLabel = _coveredArea != null
        ? 'Based on covered area ${_fmt(_coveredArea!)} sq.ft'
        : _plotArea != null
            ? 'Based on plot area ${_fmt(_plotArea!)} sq.ft (67% covered)'
            : 'Complete Module 1 & 2 first for accurate estimates.';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Material Estimation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showEditRatesDialog,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Rates'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$areaLabel${_stories != null ? ', $_stories stor${_stories == 1 ? 'y' : 'ies'}' : ''}.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Materials table
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
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Est. Cost',
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
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs ${_fmtPrice(m.cost)}',
                                      textAlign: TextAlign.end,
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      m.rate,
                                      textAlign: TextAlign.end,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Total cost card
                FluentCard(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Material Cost',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs ${_fmtPrice(_totalCost)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Grey structure materials only. Labour, finishing & transport not included.',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calculate_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ACAG Tranches
                FluentCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACAG Disbursement Phases',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTrancheRow(
                        theme,
                        'Phase 1: Foundation',
                        'Excavation, base bricks, PCC crush',
                        _totalCost * 0.30,
                      ),
                      const Divider(height: 24),
                      _buildTrancheRow(
                        theme,
                        'Phase 2: Superstructure',
                        'Walls, DPC, lintel steel',
                        _totalCost * 0.40,
                      ),
                      const Divider(height: 24),
                      _buildTrancheRow(
                        theme,
                        'Phase 3: Slab & Finishing',
                        'Roof concrete, plaster',
                        _totalCost * 0.30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

