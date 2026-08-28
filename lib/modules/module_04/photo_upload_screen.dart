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
  static const _maxPhotos = 10;

  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _photoFiles = [];

  int get _stageNo => stitchArgsFromRoute(context).stageNo ?? 1;

  String get _stageName => ConstructionStages.nameFor(_stageNo);

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCamera() async {
    if (_photoFiles.length >= _maxPhotos) {
      _showLimitSnack();
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 75,
    );
    if (picked == null) return;
    setState(() => _photoFiles.add(File(picked.path)));
  }

  Future<void> _pickGallery() async {
    if (_photoFiles.length >= _maxPhotos) {
      _showLimitSnack();
      return;
    }
    final remaining = _maxPhotos - _photoFiles.length;
    final picked = await _picker.pickMultiImage(
      maxWidth: 1280,
      imageQuality: 75,
      limit: remaining,
    );
    if (picked.isEmpty) return;
    setState(() {
      for (final item in picked) {
        if (_photoFiles.length >= _maxPhotos) break;
        _photoFiles.add(File(item.path));
      }
    });
  }

  void _removePhoto(int index) {
    setState(() => _photoFiles.removeAt(index));
  }

  void _showLimitSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You can add up to $_maxPhotos photos per stage.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submit(BuildContext context) {
    final args = stitchArgsFromRoute(context);

    if (_photoFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one progress photo.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.stitchQualityAssessment,
      arguments: args.copyWith(
        stageNo: _stageNo,
        photoPaths: _photoFiles.map((f) => f.path).toList(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[10];
    final theme = Theme.of(context);
    final hasPhotos = _photoFiles.isNotEmpty;

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
            'Current stage: $_stageName — add one or more photos.',
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
                  onTap: _pickCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'From Gallery',
                  onTap: _pickGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasPhotos)
            Text(
              '${_photoFiles.length} photo${_photoFiles.length == 1 ? '' : 's'} selected (max $_maxPhotos)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              'No photos selected yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 10),
          if (hasPhotos)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photoFiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final file = _photoFiles[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(file, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _removePhoto(index),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            FluentCard(
              padding: const EdgeInsets.all(0),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Tap Take Photo or From Gallery',
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
