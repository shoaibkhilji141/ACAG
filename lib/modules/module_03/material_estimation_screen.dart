import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class MaterialEstimationScreen extends StatelessWidget {
  const MaterialEstimationScreen({super.key});

  static const _materials = [
    (name: 'Bricks', unit: 'Nos.', qty: '28,500', rate: '14', cost: '399,000'),
    (name: 'Cement', unit: 'Bags', qty: '620', rate: '1,150', cost: '713,000'),
    (name: 'Steel (Sarya)', unit: 'Tons', qty: '3.2', rate: '285,000', cost: '912,000'),
    (name: 'Sand (Ravi)', unit: 'Cft', qty: '4,800', rate: '85', cost: '408,000'),
  ];

  static const _totalCost = '2,432,000';

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[8];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Estimated material quantities and costs for your approved structural design.',
      bottomLabel: 'Save Material Estimate',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material Estimation & Costing',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rates based on Lahore market average (Aug 2026). Includes 5% wastage.',
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
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Rate',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cost',
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
                ...List.generate(_materials.length, (i) {
                  final m = _materials[i];
                  final isLast = i == _materials.length - 1;
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
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                m.unit,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            m.qty,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            m.rate,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            m.cost,
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
          const SizedBox(height: 16),
          FluentCard(
            color: AppColors.primaryFixed.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Estimated Cost',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PKR $_totalCost',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Excludes labour, finishing & MEP works',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
