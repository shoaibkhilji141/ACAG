import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/planner_service.dart';
import '../../shared/services/project_service.dart';
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
  int _bedrooms = 2;
  int _bathrooms = 1;
  bool _loading = true;
  bool _generating = false;
  bool _saving = false;

  // Limits from the API — what this particular plot allows.
  int _bedsMin = 1, _bedsMax = 2;
  int _bathsMin = 1, _bathsMax = 2;
  List<Map<String, dynamic>> _combinations = [];
  String? _optionsNote;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    try {
      // Load previously saved values.
      final row = await ProjectService.getRoomRequirements(project.id);
      if (!mounted) return;
      if (row != null) {
        _bedrooms = (row['bedrooms'] as num?)?.toInt() ?? 2;
        _bathrooms = (row['bathrooms'] as num?)?.toInt() ?? 1;
      }

      // Ask the API what this plot allows.
      final plot = await ProjectService.getPlotDimensions(project.id);
      if (!mounted) return;
      if (plot != null) {
        final width = (plot['width'] as num?)?.toDouble() ?? 0;
        final length = (plot['length'] as num?)?.toDouble() ?? 0;
        final unit = plot['unit'] as String? ?? 'feet';
        if (width > 0 && length > 0) {
          try {
            final opts = await PlannerService.optionsForPlot(
              width: width,
              length: length,
              unit: unit,
            );
            if (!mounted) return;
            _bedsMin = (opts['bedrooms']?['min'] as num?)?.toInt() ?? 1;
            _bedsMax = (opts['bedrooms']?['max'] as num?)?.toInt() ?? 2;
            _bathsMin = (opts['bathrooms']?['min'] as num?)?.toInt() ?? 1;
            _bathsMax = (opts['bathrooms']?['max'] as num?)?.toInt() ?? 2;
            _combinations = List<Map<String, dynamic>>.from(
                (opts['combinations'] as List?) ?? []);
            _optionsNote = opts['note'] as String?;
          } catch (_) {
            // API not reachable — use safe defaults, generate will still work.
          }
        }
      }

      // Clamp to allowed range.
      _bedrooms = _bedrooms.clamp(_bedsMin, _bedsMax);
      _bathrooms = _bathrooms.clamp(_bathsMin, _effectiveBathsMax);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Whether this particular combination is possible.
  bool _comboAllowed(int beds, int baths) {
    if (_combinations.isEmpty) return true; // no data — allow everything
    return _combinations.any((c) =>
        c['bedrooms'] == beds &&
        c['bathrooms'] == baths &&
        c['possible'] == true);
  }

  /// The reason a combination is not possible (from the API).
  String? _comboReason(int beds, int baths) {
    final c = _combinations.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c?['bedrooms'] == beds && c?['bathrooms'] == baths,
          orElse: () => null,
        );
    return c?['why_not'] as String?;
  }

  /// Max baths allowed given the currently selected bedroom count.
  int get _effectiveBathsMax {
    if (_combinations.isEmpty) return _bathsMax;
    int max = _bathsMin;
    for (final c in _combinations) {
      if (c['bedrooms'] == _bedrooms &&
          c['possible'] == true &&
          (c['bathrooms'] as int) > max) {
        max = c['bathrooms'] as int;
      }
    }
    return max;
  }

  void _adjustBeds(int delta) {
    setState(() {
      _bedrooms = (_bedrooms + delta).clamp(_bedsMin, _bedsMax);
      // Re-clamp baths after bedroom change.
      _bathrooms = _bathrooms.clamp(_bathsMin, _effectiveBathsMax);
    });
  }

  void _adjustBaths(int delta) {
    final newVal = (_bathrooms + delta).clamp(_bathsMin, _bathsMax);
    if (!_comboAllowed(_bedrooms, newVal)) {
      final reason = _comboReason(_bedrooms, newVal);
      if (reason != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reason), backgroundColor: AppColors.error),
        );
      }
      return;
    }
    setState(() => _bathrooms = newVal);
  }

  Future<void> _generate() async {
    final screen = stitchScreens[1];
    final project = projectFromRoute(context);
    if (_bedrooms < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 1 bedroom required')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _generating = true;
    });

    try {
      // 1. Save room requirements to Supabase.
      await ProjectService.saveRoomRequirements(
        projectCodeOrId: project.id,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        toilets: 0,
        kitchens: 1,
      );

      // 2. Get the plot dimensions for the API call.
      final plot = await ProjectService.getPlotDimensions(project.id);
      if (!mounted) return;
      if (plot == null) {
        throw Exception('Plot dimensions not found — go back and enter them');
      }

      final width = (plot['width'] as num).toDouble();
      final length = (plot['length'] as num).toDouble();
      final unit = plot['unit'] as String? ?? 'feet';
      final zone = plot['geographic_zone'] as String? ?? 'punjab_plains';
      final totalArea = (plot['total_area'] as num?)?.toDouble();

      // 3. Call the plan generator API.
      final result = await PlannerService.generateFloorPlans(
        unit: unit,
        width: width,
        length: length,
        totalArea: totalArea,
        geographicZone: zone,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        projectId: project.id,
      );

      if (!mounted) return;

      // 4. Cache the result and navigate to the floor plans screen.
      PlannerService.cacheResult(result);
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
      if (mounted) {
        setState(() {
          _saving = false;
          _generating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[1];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Specify room counts to generate floor plan options for your plot.',
      bottomLabel: _generating
          ? 'Generating plans…'
          : _saving
              ? 'Saving…'
              : 'Generate Floor Plans',
      onBottomPressed: (_loading || _saving) ? null : _generate,
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
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
                  'Budget scheme: 400-500 sq ft covered area.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Bedrooms
                _buildCounter(
                  theme,
                  label: 'Bedrooms',
                  icon: Icons.bed_outlined,
                  value: _bedrooms,
                  min: _bedsMin,
                  max: _bedsMax,
                  onMinus: () => _adjustBeds(-1),
                  onPlus: () => _adjustBeds(1),
                ),
                const SizedBox(height: 10),
                // Bathrooms
                _buildCounter(
                  theme,
                  label: 'Bathrooms',
                  icon: Icons.bathtub_outlined,
                  value: _bathrooms,
                  min: _bathsMin,
                  max: _bathsMax,
                  onMinus: () => _adjustBaths(-1),
                  onPlus: () => _adjustBaths(1),
                ),
                const SizedBox(height: 10),
                // Kitchen (always 1, shown but not adjustable)
                FluentCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.kitchen_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Kitchen',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '1',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(always included)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FluentCard(
                  color: AppColors.primaryFixed.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lounge and kitchen are always included. '
                          'Plans will be optimised for Punjab housing norms.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_generating) ...[
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Drawing floor plans — about 3 seconds…',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildCounter(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required int value,
    required int min,
    required int max,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return FluentCard(
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
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.remove,
            enabled: value > min,
            onTap: onMinus,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add,
            enabled: value < max,
            onTap: onPlus,
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
