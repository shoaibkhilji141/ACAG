import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/planner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../shared/widgets/zoomable_image.dart';
import '../../theme/app_theme.dart';

class ElevationDesignScreen extends StatefulWidget {
  const ElevationDesignScreen({super.key});

  @override
  State<ElevationDesignScreen> createState() => _ElevationDesignScreenState();
}

class _ElevationDesignScreenState extends State<ElevationDesignScreen> {
  int _selectedSide = 0;
  bool _loading = true;
  bool _saving = false;

  // The four real elevation URLs from the API.
  final _sides = <({String key, String label, String? url})>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    // Pick up the elevation URLs cached by the floor-plans screen.
    final cached = PlannerService.peekResult();
    if (cached != null) {
      _sides.addAll([
        (
          key: 'front',
          label: 'Front Elevation',
          url: cached['front_elevation_url'] as String?
        ),
        (
          key: 'back',
          label: 'Back Elevation',
          url: cached['back_elevation_url'] as String?
        ),
        (
          key: 'left',
          label: 'Left Elevation',
          url: cached['left_elevation_url'] as String?
        ),
        (
          key: 'right',
          label: 'Right Elevation',
          url: cached['right_elevation_url'] as String?
        ),
      ]);
    }

    // If no cache, try loading existing selection from Supabase.
    if (cached != null) {
      // Keep foundation and services around for the next screens
      PlannerService.cacheResult({
        'foundation_plan_url': cached['foundation_plan_url'],
        'foundation_plan_lb': cached['foundation_plan_lb'],
        'foundation_plan_rcc': cached['foundation_plan_rcc'],
        'services_details_url': cached['services_details_url'],
      });
    }
    
    if (_sides.isEmpty) {
      final project = projectFromRoute(context);
      try {
        final rows = await ProjectService.getElevationDesigns(project.id);
        if (rows.isNotEmpty) {
          final sel = rows.indexWhere((r) => r['is_selected'] == true);
          if (sel >= 0) _selectedSide = sel;
        }
      } catch (_) {}
      // Fall back to placeholder labels if nothing is available.
      if (_sides.isEmpty) {
        _sides.addAll([
          (key: 'front', label: 'Front Elevation', url: null),
          (key: 'back', label: 'Back Elevation', url: null),
          (key: 'left', label: 'Left Elevation', url: null),
          (key: 'right', label: 'Right Elevation', url: null),
        ]);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final screen = stitchScreens[3];
    final project = projectFromRoute(context);
    setState(() => _saving = true);
    try {
      await ProjectService.saveElevationSelection(
        projectCodeOrId: project.id,
        selectedStyleKey: _sides[_selectedSide].key,
        styles: _sides
            .map(
              (s) => {
                'style_key': s.key,
                'title': s.label,
              },
            )
            .toList(),
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
    final screen = stitchScreens[3];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'View your home\'s elevation drawings — generated from the selected plan.',
      bottomLabel: _saving ? 'Saving…' : 'Save Elevation Design',
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
                  'Elevation Drawings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These elevations are drawn from your selected floor plan.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // The selected elevation image — large.
                if (_sides.isNotEmpty) ...[
                  FluentCard(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        if (_sides[_selectedSide].url != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: ZoomableImage(
                                      imageUrl: _sides[_selectedSide].url!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                          )
                        else
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Elevation image not available',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(Icons.home_outlined,
                                  color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                _sides[_selectedSide].label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'View from',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Side selector.
                  ...List.generate(_sides.length, (i) {
                    final s = _sides[i];
                    final selected = _selectedSide == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSide = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryFixed
                                    .withValues(alpha: 0.2)
                                : AppColors.surfaceLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant
                                      .withValues(alpha: 0.5),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _iconForSide(s.key),
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  s.label,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.radio_button_checked,
                                  color: AppColors.primary,
                                )
                              else
                                Icon(
                                  Icons.radio_button_off,
                                  color: AppColors.outline
                                      .withValues(alpha: 0.6),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }

  IconData _iconForSide(String key) {
    switch (key) {
      case 'front':
        return Icons.home_outlined;
      case 'back':
        return Icons.home_work_outlined;
      case 'left':
        return Icons.arrow_back;
      case 'right':
        return Icons.arrow_forward;
      default:
        return Icons.home_outlined;
    }
  }
}
