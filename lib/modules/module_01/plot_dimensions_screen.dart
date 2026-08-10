import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class PlotDimensionsScreen extends StatefulWidget {
  const PlotDimensionsScreen({super.key});

  @override
  State<PlotDimensionsScreen> createState() => _PlotDimensionsScreenState();
}

class _PlotDimensionsScreenState extends State<PlotDimensionsScreen> {
  int _unitIndex = 0;
  final _lengthController = TextEditingController(text: '50');
  final _widthController = TextEditingController(text: '70');
  int _zoneIndex = 0;

  static const _units = ['Feet', 'Meters', 'Marla'];
  static const _zones = [
    ('Punjab Plains', 'Lahore, Multan, Faisalabad', 'Flat / Modern'),
    ('Northern Areas', 'Murree, Abbottabad, Swat', 'Sloped Roof'),
    ('Sindh Coastal', 'Karachi, Hyderabad', 'Ventilated'),
    ('Balochistan', 'Quetta, Gwadar', 'Earth Tones'),
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  int get _area {
    final length = int.tryParse(_lengthController.text) ?? 0;
    final width = int.tryParse(_widthController.text) ?? 0;
    return length * width;
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[0];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Enter plot dimensions to generate floor plans and elevation designs.',
      bottomLabel: 'Continue to Room Requirements',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plot Dimensions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_units.length, (i) {
                final selected = _unitIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _unitIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _units[i],
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: selected
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DimensionField(
                  label: 'Length (${_units[_unitIndex].toLowerCase()})',
                  controller: _lengthController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                child: Icon(Icons.close, color: AppColors.outline),
              ),
              Expanded(
                child: _DimensionField(
                  label: 'Width (${_units[_unitIndex].toLowerCase()})',
                  controller: _widthController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FluentCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Plot Area',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_area sq.ft',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.square_foot_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Geographic Zone',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Elevation design auto-assigned based on your zone',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _zones.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final selected = _zoneIndex == i;
              final zone = _zones[i];
              return GestureDetector(
                onTap: () => setState(() => _zoneIndex = i),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryFixed.withValues(alpha: 0.25)
                        : AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              zone.$1,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        zone.$2,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Style: ${zone.$3}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DimensionField extends StatelessWidget {
  const _DimensionField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
