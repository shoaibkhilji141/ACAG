import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/planner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../shared/widgets/zoomable_image.dart';
import '../../theme/app_theme.dart';

class GeneratedFloorPlansScreen extends StatefulWidget {
  const GeneratedFloorPlansScreen({super.key});

  @override
  State<GeneratedFloorPlansScreen> createState() =>
      _GeneratedFloorPlansScreenState();
}

class _GeneratedFloorPlansScreenState extends State<GeneratedFloorPlansScreen> {
  int _selectedPlan = 0;
  bool _loading = true;
  bool _saving = false;

  List<Map<String, dynamic>> _plans = [];
  String? _note;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    // Pick up the result cached by the room-requirements screen.
    final result = PlannerService.peekResult();
    if (result != null) {
      final rows = result['floor_plans'] as List?;
      if (rows != null && rows.isNotEmpty) {
        _plans = List<Map<String, dynamic>>.from(rows);
        _note = result['note'] as String?;
      }
    }

    // If we got nothing from the cache (e.g. screen was revisited), check
    // Supabase for a previously saved selection.
    if (_plans.isEmpty) {
      final project = projectFromRoute(context);
      try {
        final rows = await ProjectService.getFloorPlans(project.id);
        if (rows.isNotEmpty) {
          _plans = rows;
          final idx = rows.indexWhere((r) => r['is_selected'] == true);
          if (idx >= 0) _selectedPlan = idx;
        }
      } catch (_) {}
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _continue() async {
    if (_plans.isEmpty) return;
    final screen = stitchScreens[2];
    final project = projectFromRoute(context);
    final plan = _plans[_selectedPlan];

    setState(() => _saving = true);
    try {
      // Download all images from the API before they expire (6 hours).
      // Use Future.wait to download them concurrently for speed.
      final results = await Future.wait([
        PlannerService.downloadAsBase64(plan['image_url'] as String),
        PlannerService.downloadAsBase64(plan['front_elevation_url'] as String),
        PlannerService.downloadAsBase64(plan['back_elevation_url'] as String),
        PlannerService.downloadAsBase64(plan['left_elevation_url'] as String),
        PlannerService.downloadAsBase64(plan['right_elevation_url'] as String),
        PlannerService.downloadAsBase64(plan['foundation_plan_lb'] as String),
        PlannerService.downloadAsBase64(plan['foundation_plan_rcc'] as String),
        PlannerService.downloadAsBase64(plan['services_details_url'] as String),
      ]);

      final planImageB64 = results[0];
      final frontElevB64 = results[1];
      final backElevB64 = results[2];
      final leftElevB64 = results[3];
      final rightElevB64 = results[4];
      final foundationLbB64 = results[5];
      final foundationRccB64 = results[6];
      final servicesB64 = results[7];

      // Save all options with images to Supabase.
      await ProjectService.saveFloorPlanSelection(
        projectCodeOrId: project.id,
        selectedOptionKey: plan['option_key'] as String,
        options: _plans
            .map(
              (p) => {
                'option_key': p['option_key'],
                'title': p['title'],
                'description': p['description'],
                // Only save full image data for the selected plan.
                if (p['option_key'] == plan['option_key']) ...{
                  'plan_image_base64': planImageB64,
                  'front_elevation_base64': frontElevB64,
                  'back_elevation_base64': backElevB64,
                  'left_elevation_base64': leftElevB64,
                  'right_elevation_base64': rightElevB64,
                  'foundation_plan_lb_base64': foundationLbB64,
                  'foundation_plan_rcc_base64': foundationRccB64,
                  'services_details_base64': servicesB64,
                  'area_sqft': p['area_sqft'],
                  'rooms_json': p['rooms'],
                  'warnings_json': p['warnings'],
                },
              },
            )
            .toList(),
      );

      // Also cache the selected plan's elevation URLs so the elevation screen
      // can show them.
      PlannerService.cacheResult({
        'front_elevation_url': frontElevB64,
        'back_elevation_url': backElevB64,
        'left_elevation_url': leftElevB64,
        'right_elevation_url': rightElevB64,
        'foundation_plan_lb': foundationLbB64,
        'foundation_plan_rcc': foundationRccB64,
        'services_details_url': servicesB64,
      });

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
    final screen = stitchScreens[2];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'AI-generated floor plans based on your plot size and room requirements.',
      bottomLabel: _saving ? 'Saving plan…' : 'Continue to Elevation Design',
      onBottomPressed: (_loading || _saving || _plans.isEmpty) ? null : _continue,
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : _plans.isEmpty
              ? Center(
                  child: Text(
                    'No plans generated yet. Go back and enter your plot and room details.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generated Floor Plans',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a floor plan to proceed with elevation design.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (_note != null && _note!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      FluentCard(
                        color: AppColors.primaryFixed.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _note!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ...List.generate(_plans.length, (i) {
                      final plan = _plans[i];
                      final selected = _selectedPlan == i;
                      final title = plan['title'] as String? ?? 'Plan ${i + 1}';
                      final area = plan['area_sqft'];
                      final imageUrl = plan['image_url'] as String?;
                      final rooms =
                          List<String>.from((plan['rooms'] as List?) ?? []);
                      final warnings =
                          List<String>.from((plan['warnings'] as List?) ?? []);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPlan = i),
                          child: FluentCard(
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant
                                      .withValues(alpha: 0.5),
                              width: selected ? 2 : 1,
                            ),
                            color: selected
                                ? AppColors.primaryFixed
                                    .withValues(alpha: 0.12)
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // The real floor plan image from the API.
                                if (imageUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ZoomableImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                if (area != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.square_foot_outlined,
                                        size: 16,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$area sq.ft covered',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (rooms.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: rooms.map((r) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          r,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
