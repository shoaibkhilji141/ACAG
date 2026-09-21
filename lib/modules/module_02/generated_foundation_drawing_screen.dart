import 'package:flutter/material.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/planner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../shared/widgets/zoomable_image.dart';
import '../../theme/app_theme.dart';

class GeneratedFoundationDrawingScreen extends StatefulWidget {
  const GeneratedFoundationDrawingScreen({super.key});

  @override
  State<GeneratedFoundationDrawingScreen> createState() =>
      _GeneratedFoundationDrawingScreenState();
}

class _GeneratedFoundationDrawingScreenState
    extends State<GeneratedFoundationDrawingScreen> {
  bool _saving = false;
  String? _foundationUrl;
  bool _loading = true;
  Map<String, dynamic>? _cachedResult;
  bool _isRcc = false;

  @override
  void initState() {
    super.initState();
    final cached = PlannerService.peekResult();
    if (cached != null) {
      _cachedResult = cached;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    try {
      final frameType = await ProjectService.getStructuralFrame(project.id);
      if (!mounted) return;
      
      _isRcc = (frameType != null && (frameType['frame_type'] as String?)?.contains('RCC') == true);
      if (_cachedResult != null) {
        _foundationUrl = _isRcc
            ? _cachedResult!['foundation_plan_rcc'] as String?
            : _cachedResult!['foundation_plan_lb'] as String?;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<(String, String)> get _specs => _isRcc ? [
    ('Foundation Type', 'Isolated Footing + Plinth Beam'),
    ('Depth Below NGL', '3.0 ft (Min)'),
    ('Concrete Grade', 'M25 (1:1.5:3)'),
    ('Steel Reinforcement', 'Fe-500, #4 Main Bars'),
    ('Plinth Height', '1.0 ft above ground'),
    ('Column Size', '9" x 9"'),
  ] : [
    ('Foundation Type', 'Strip Footing + Plinth Beam'),
    ('Depth Below NGL', '1.8 m'),
    ('Concrete Grade', 'M25 (1:1:2)'),
    ('Steel Reinforcement', 'Fe-500, 12mm & 16mm bars'),
    ('Plinth Height', '450 mm above ground'),
    ('DPC Layer', 'Bitumen + polythene sheet'),
  ];

  Future<void> _continue() async {
    final screen = stitchScreens[7];
    final project = projectFromRoute(context);
    setState(() => _saving = true);
    try {
      await ProjectService.saveFoundationDrawing(
        projectCodeOrId: project.id,
        summaryJson: {for (final s in _specs) s.$1: s.$2},
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
    final screen = stitchScreens[7];
    final theme = Theme.of(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Auto-generated foundation drawing based on your chosen structural frame type.',
      bottomLabel: _saving ? 'Saving…' : 'Continue to Material Estimation',
      onBottomPressed: (_loading || _saving) ? null : _continue,
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Foundation Drawing',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review structural specifications before selecting frame type.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FluentCard(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (_foundationUrl != null)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ZoomableImage(
                                      imageUrl: _foundationUrl!,
                                      fit: BoxFit.contain,
                                    ),
                          ),
                        )
                      else
                        CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: _FoundationDrawingPainter(),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AUTO-GENERATED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 12,
                        child: Text(
                          'Section A-A — Foundation Detail',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Technical Specifications',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._specs.map((spec) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 140,
                                child: Text(
                                  spec.$1,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  spec.$2,
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
          ),
          const SizedBox(height: 12),
          FluentCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Drawing complies with NBC Pakistan 2021 and Punjab Building Authority standards.',
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

class _FoundationDrawingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ground = Paint()..color = AppColors.tertiaryFixed.withValues(alpha: 0.4);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.65),
      ground,
    );

    final footing = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.5, size.width * 0.7, 28),
      footing,
    );

    final wall = Paint()..color = AppColors.outline.withValues(alpha: 0.7);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.42, size.height * 0.2, size.width * 0.16, size.height * 0.3),
      wall,
    );

    final beam = Paint()..color = AppColors.primary.withValues(alpha: 0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.42, size.width * 0.8, 10),
      beam,
    );

    final dimLine = Paint()
      ..color = AppColors.error
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.5),
      Offset(size.width * 0.08, size.height * 0.78),
      dimLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
