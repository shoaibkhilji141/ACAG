import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_stages.dart';
import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  File? _photoFile;

  int get _stageNo => stitchArgsFromRoute(context).stageNo ?? 1;

  String get _stageName => ConstructionStages.nameFor(_stageNo);

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 75,
    );
    if (picked == null) return;
    setState(() => _photoFile = File(picked.path));
  }

  void _submit(BuildContext context) {
    final args = stitchArgsFromRoute(context);

    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take or select a progress photo first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.stitchQualityAssessment,
      arguments: args.copyWith(
        stageNo: _stageNo,
        photoPath: _photoFile!.path,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[10];
    final theme = Theme.of(context);
    final hasPhoto = _photoFile != null;

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Document on-site progress with geo-tagged photos for QA review.',
      bottomLabel: 'Next — Quality Assessment',
      onBottomPressed: () => _submit(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Progress Photos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current stage: $_stageName — GPS verification enabled.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PhotoActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  onTap: () => _pick(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'From Gallery',
                  onTap: () => _pick(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FluentCard(
            padding: const EdgeInsets.all(0),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: hasPhoto
                    ? AppColors.surfaceLow
                    : AppColors.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_photoFile!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS Verified',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'No photo selected',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              filled: true,
              fillColor: AppColors.surfaceLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  const _PhotoActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surfaceLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
