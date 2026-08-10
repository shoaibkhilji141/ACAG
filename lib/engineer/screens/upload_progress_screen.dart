import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_theme.dart';
import 'project_details_screen.dart';

class UploadProgressScreen extends StatefulWidget {
  const UploadProgressScreen({super.key});

  @override
  State<UploadProgressScreen> createState() => _UploadProgressScreenState();
}

class _UploadProgressScreenState extends State<UploadProgressScreen> {
  int _selectedStage = 3;
  final _notesController = TextEditingController();
  bool _photoAttached = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _attachPhoto() async {
    final project = projectFromRoute(context);
    await Navigator.of(context).pushNamed(
      AppRoutes.engineerCamera,
      arguments: project,
    );
    if (mounted) setState(() => _photoAttached = true);
  }

  Future<void> _submit() async {
    final project = projectFromRoute(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 10),
            Text('Progress Submitted'),
          ],
        ),
        content: const Text(
          'Your progress update has been recorded. Proceeding to AI validation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppRoutes.engineerAi,
      arguments: project,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);
    final stages = MockData.stages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Progress'),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select construction stage and add notes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Construction Stage',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < stages.length; i++)
                  ChoiceChip(
                    label: Text(stages[i].title),
                    selected: _selectedStage == i,
                    onSelected: (_) => setState(() => _selectedStage = i),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: _selectedStage == i
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: _selectedStage == i
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: _selectedStage == i
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe progress, materials used, observations...',
                filled: true,
                fillColor: AppColors.surfaceLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FluentCard(
              onTap: _attachPhoto,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _photoAttached
                          ? Icons.check_circle_outline
                          : Icons.add_a_photo_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _photoAttached ? 'Photo Attached' : 'Attach Photo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          _photoAttached
                              ? 'Site photo captured successfully'
                              : 'Take or select a site photo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.outline),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Submit Progress',
              icon: Icons.cloud_upload_outlined,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
