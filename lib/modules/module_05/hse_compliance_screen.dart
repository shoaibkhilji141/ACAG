import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class HseComplianceScreen extends StatefulWidget {
  const HseComplianceScreen({super.key});

  @override
  State<HseComplianceScreen> createState() => _HseComplianceScreenState();
}

class _HseComplianceScreenState extends State<HseComplianceScreen> {
  final _items = [
    (question: 'Safety helmets worn by all workers on site?', answer: true),
    (question: 'Scaffolding properly secured and inspected?', answer: true),
    (question: 'Fire extinguishers available at each floor?', answer: false),
    (question: 'Electrical wiring meets NBC safety standards?', answer: true),
    (question: 'First aid kit stocked and accessible?', answer: true),
    (question: 'Waste disposal follows EPA Punjab guidelines?', answer: null),
    (question: 'Fall protection used for work above 2m height?', answer: true),
  ];

  void _setAnswer(int index, bool? value) {
    setState(() {
      final item = _items[index];
      _items[index] = (question: item.question, answer: value);
    });
  }

  int get _yesCount => _items.where((i) => i.answer == true).length;

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[13];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Health, Safety & Environment compliance checklist for project handover.',
      bottomLabel: 'Save HSE Assessment',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HSE Compliance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verify all safety requirements before final certificate issuance.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FluentCard(
            color: AppColors.primaryFixed.withValues(alpha: 0.15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_yesCount of ${_items.length} items compliant',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Minimum 6/7 required for certification',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FluentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _YesNoButton(
                          label: 'Yes',
                          selected: item.answer == true,
                          color: AppColors.success,
                          onTap: () => _setAnswer(i, true),
                        ),
                        const SizedBox(width: 10),
                        _YesNoButton(
                          label: 'No',
                          selected: item.answer == false,
                          color: AppColors.error,
                          onTap: () => _setAnswer(i, false),
                        ),
                        const Spacer(),
                        if (item.answer == null)
                          Text(
                            'Not answered',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                      ],
                    ),
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

class _YesNoButton extends StatelessWidget {
  const _YesNoButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.15) : AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
