import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/stitch_screens.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class SoilAnalysisDetailsScreen extends StatefulWidget {
  const SoilAnalysisDetailsScreen({super.key});

  @override
  State<SoilAnalysisDetailsScreen> createState() =>
      _SoilAnalysisDetailsScreenState();
}

class _SoilAnalysisDetailsScreenState extends State<SoilAnalysisDetailsScreen> {
  int _soilTypeIndex = 0;
  File? _evidencePhoto;
  String? _evidenceBase64;
  bool _savingPhoto = false;
  bool _loading = true;
  bool _saving = false;
  final _bearingController = TextEditingController();
  final _waterTableController = TextEditingController();
  final _picker = ImagePicker();

  static const _soilTypes = [
    ('Clayey Soil', 'High cohesion, moderate bearing'),
    ('Sandy Soil', 'Good drainage, requires compaction'),
    ('Loamy Soil', 'Balanced — ideal for residential'),
    ('Rocky Substrate', 'Excellent bearing capacity'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _bearingController.dispose();
    _waterTableController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final project = projectFromRoute(context);
    try {
      final row = await ProjectService.getSoilAnalysis(project.id);
      if (!mounted) return;
      if (row != null) {
        final type = row['soil_type'] as String? ?? '';
        final idx = _soilTypes.indexWhere((s) => s.$1 == type);
        if (idx >= 0) _soilTypeIndex = idx;
        final bearing = row['bearing_capacity_kn_m2'];
        final water = row['water_table_depth_m'];
        if (bearing != null) {
          _bearingController.text = bearing is num
              ? (bearing == bearing.roundToDouble()
                  ? '${bearing.round()}'
                  : bearing.toStringAsFixed(1))
              : '$bearing';
        }
        if (water != null) {
          _waterTableController.text = water is num
              ? (water == water.roundToDouble()
                  ? '${water.round()}'
                  : water.toStringAsFixed(1))
              : '$water';
        }
        _evidenceBase64 = row['evidence_photo_base64'] as String?;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continue() async {
    final screen = stitchScreens[5];
    final project = projectFromRoute(context);
    setState(() => _saving = true);
    try {
      final bearing = double.tryParse(_bearingController.text);
      final water = double.tryParse(_waterTableController.text);
      final note =
          'Recommended foundation: ${_soilTypeIndex <= 1 ? 'Raft' : 'Strip'} '
          'footing at ${(water ?? 2.5) + 1.2}m depth.';
      await ProjectService.saveSoilAnalysis(
        projectCodeOrId: project.id,
        soilType: _soilTypes[_soilTypeIndex].$1,
        bearingCapacity: bearing,
        waterTableDepth: water,
        recommendedNote: note,
        evidencePhotoBase64: _evidenceBase64,
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

  Future<void> _pickEvidencePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 75,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _evidencePhoto = file;
      _savingPhoto = true;
    });

    try {
      final project = projectFromRoute(context);
      final base64 = await encodeFileToBase64(file);
      await ProjectService.addProjectImageBase64(
        projectCodeOrId: project.id,
        imageBase64: base64,
        caption: 'Soil site evidence',
      );
      if (!mounted) return;
      setState(() {
        _evidenceBase64 = base64;
        _savingPhoto = false;
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Evidence photo saved to project images')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingPhoto = false);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[5];
    final theme = Theme.of(context);
    projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Enter soil test results for foundation design and depth recommendations.',
      bottomLabel: _saving ? 'Saving…' : 'Generate Foundation Drawing',
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
            'Soil Analysis Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on borehole test at plot centre (NBC Pakistan guidelines).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Soil Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_soilTypes.length, (i) {
            final soil = _soilTypes[i];
            final selected = _soilTypeIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _soilTypeIndex = i),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryFixed.withValues(alpha: 0.2)
                        : AppColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        color: selected ? AppColors.primary : AppColors.outline,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              soil.$1,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              soil.$2,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SoilField(
                  label: 'Bearing Capacity',
                  controller: _bearingController,
                  suffix: 'kN/m²',
                  icon: Icons.compress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SoilField(
                  label: 'Water Table Depth',
                  controller: _waterTableController,
                  suffix: 'm',
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FluentCard(
            color: AppColors.info.withValues(alpha: 0.08),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science_outlined, color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recommended foundation: ${_soilTypeIndex <= 1 ? 'Raft' : 'Strip'} '
                    'footing at ${(double.tryParse(_waterTableController.text) ?? 2.5) + 1.2}m depth.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SiteEvidencePhotoCard(
            hasPhoto: _evidencePhoto != null ||
                (_evidenceBase64 != null && _evidenceBase64!.isNotEmpty),
            saving: _savingPhoto,
            preview: _evidencePhoto,
            onTap: _savingPhoto ? null : _pickEvidencePhoto,
          ),
        ],
      ),
    );
  }
}

class _SiteEvidencePhotoCard extends StatelessWidget {
  const _SiteEvidencePhotoCard({
    required this.hasPhoto,
    required this.saving,
    required this.onTap,
    this.preview,
  });

  final bool hasPhoto;
  final bool saving;
  final VoidCallback? onTap;
  final File? preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FluentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Evidence Photo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: AppColors.outlineVariant.withValues(alpha: 0.8),
                  radius: 12,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: saving
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : Column(
                          children: [
                            if (preview != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  preview!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Icon(
                              hasPhoto
                                  ? Icons.check_circle_outline
                                  : Icons.photo_camera_outlined,
                              size: 28,
                              color: hasPhoto
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              hasPhoto
                                  ? 'Site evidence photo added'
                                  : 'Upload site evidence photo',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Photo of exposed soil at excavation',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is evidence documentation, not the basis of classification.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.outline,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLength = 6.0;
    const dashGap = 4.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _SoilField extends StatelessWidget {
  const _SoilField({
    required this.label,
    required this.controller,
    required this.suffix,
    required this.icon,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLowest,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
