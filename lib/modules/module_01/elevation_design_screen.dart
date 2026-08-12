import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class ElevationDesignScreen extends StatefulWidget {
  const ElevationDesignScreen({super.key});

  @override
  State<ElevationDesignScreen> createState() => _ElevationDesignScreenState();
}

class _ElevationDesignScreenState extends State<ElevationDesignScreen> {
  int _selectedStyle = 0;
  bool _loading = true;
  bool _saving = false;

  static const _styles = [
    (
      key: 'modern',
      name: 'Modern',
      subtitle: 'Clean lines, flat roof, glass accents',
      colors: [Color(0xFFE8EEFF), Color(0xFF00512C)],
      icon: Icons.apartment,
    ),
    (
      key: 'traditional',
      name: 'Traditional',
      subtitle: 'Arched windows, decorative cornices',
      colors: [Color(0xFFFFDCBD), Color(0xFF683B00)],
      icon: Icons.account_balance,
    ),
    (
      key: 'contemporary',
      name: 'Contemporary',
      subtitle: 'Mixed materials, cantilever elements',
      colors: [Color(0xFFD7E3F9), Color(0xFF535F71)],
      icon: Icons.domain,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    try {
      final rows = await ProjectService.getElevationDesigns(project.id);
      if (!mounted) return;
      final selected = rows.cast<Map<String, dynamic>?>().firstWhere(
            (r) => r?['is_selected'] == true,
            orElse: () => null,
          );
      if (selected != null) {
        final key = selected['style_key'] as String?;
        final idx = _styles.indexWhere((s) => s.key == key);
        if (idx >= 0) _selectedStyle = idx;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final screen = stitchScreens[3];
    final project = projectFromRoute(context);
    setState(() => _saving = true);
    try {
      await ProjectService.saveElevationSelection(
        projectCodeOrId: project.id,
        selectedStyleKey: _styles[_selectedStyle].key,
        styles: _styles
            .map(
              (s) => {
                'style_key': s.key,
                'title': s.name,
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
    final style = _styles[_selectedStyle];

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Choose an elevation style matched to your geographic zone and preferences.',
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
                  'Elevation Design',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preview how your home will look from the street.',
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
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              style.colors[0],
                              style.colors[0].withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: CustomPaint(
                          painter: _ElevationPreviewPainter(
                            accent: style.colors[1],
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                '${style.name} Elevation Preview',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: style.colors[1],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(style.icon, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    style.subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
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
                  'Elevation Style',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(_styles.length, (i) {
                  final s = _styles[i];
                  final selected = _selectedStyle == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStyle = i),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryFixed.withValues(alpha: 0.2)
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
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: s.colors[0],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: s.colors[1], width: 2),
                              ),
                              child: Icon(s.icon, color: s.colors[1], size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    s.subtitle,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
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
                                color: AppColors.outline.withValues(alpha: 0.6),
                              ),
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

class _ElevationPreviewPainter extends CustomPainter {
  _ElevationPreviewPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final house = Paint()..color = accent.withValues(alpha: 0.85);
    final roof = Paint()..color = accent;

    final base = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.5,
      size.height * 0.4,
    );
    canvas.drawRect(base, house);

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.45)
      ..close();
    canvas.drawPath(path, roof);

    final window = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.55, 24, 24),
      window,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.55, 24, 24),
      window,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.72, 20, 32),
      window,
    );
  }

  @override
  bool shouldRepaint(covariant _ElevationPreviewPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
