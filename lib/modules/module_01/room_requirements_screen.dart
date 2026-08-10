import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class RoomRequirementsScreen extends StatefulWidget {
  const RoomRequirementsScreen({super.key});

  @override
  State<RoomRequirementsScreen> createState() => _RoomRequirementsScreenState();
}

class _RoomRequirementsScreenState extends State<RoomRequirementsScreen> {
  final _counts = <String, int>{
    'Bedrooms': 3,
    'Bathrooms': 2,
    'Toilets': 2,
    'Kitchens': 1,
  };

  static const _icons = {
    'Bedrooms': Icons.bed_outlined,
    'Bathrooms': Icons.bathtub_outlined,
    'Toilets': Icons.wc_outlined,
    'Kitchens': Icons.kitchen_outlined,
  };

  void _adjust(String key, int delta) {
    setState(() {
      _counts[key] = (_counts[key]! + delta).clamp(0, 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[1];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Specify room counts to generate floor plan options for your plot.',
      bottomLabel: 'Generate Floor Plans',
      onBottomPressed: () => navigateStitchNext(context, screen),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Requirements',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adjust counts for each room type. Minimum 1 bedroom required.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ..._counts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FluentCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _icons[entry.key],
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CounterButton(
                      icon: Icons.remove,
                      enabled: entry.value > 0,
                      onTap: () => _adjust(entry.key, -1),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${entry.value}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _CounterButton(
                      icon: Icons.add,
                      enabled: entry.value < 10,
                      onTap: () => _adjust(entry.key, 1),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          FluentCard(
            color: AppColors.primaryFixed.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Total rooms: ${_counts.values.reduce((a, b) => a + b)} — '
                    'Floor plans will be optimised for Punjab housing norms.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
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

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.surfaceContainer
          : AppColors.surfaceContainer.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.primary : AppColors.outline,
          ),
        ),
      ),
    );
  }
}
