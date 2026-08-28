import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/construction_stages.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/image_preview_dialog.dart';
import '../../theme/app_theme.dart';

class StageDetailScreen extends StatefulWidget {
  const StageDetailScreen({super.key});

  @override
  State<StageDetailScreen> createState() => _StageDetailScreenState();
}

class _StageDetailScreenState extends State<StageDetailScreen> {
  Map<String, dynamic>? _stage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final args = stitchArgsFromRoute(context);
    final stageNo = args.stageNo;
    if (stageNo == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final row = await ProjectService.getConstructionStage(
        args.project.id,
        stageNo,
      );
      if (!mounted) return;
      setState(() {
        _stage = row;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = stitchArgsFromRoute(context);
    final stageNo = args.stageNo ?? 0;
    final theme = Theme.of(context);
    final stageName = ConstructionStages.nameFor(stageNo);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Stage $stageNo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stage == null
              ? Center(
                  child: Text(
                    'Stage data not found.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stageName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_stage!['completed_at'] as String?),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => showBase64ImagePreview(
                          context,
                          imageBase64:
                              _stage!['image_base64'] as String?,
                          caption: _stage!['description'] as String?,
                        ),
                        child: FluentCard(
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: _buildImage(
                                _stage!['image_base64'] as String?,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FluentCard(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          (_stage!['description'] as String?)?.trim().isNotEmpty ==
                                  true
                              ? (_stage!['description'] as String).trim()
                              : 'No description provided.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildImage(String? base64) {
    final bytes = decodeBase64Image(base64);
    if (bytes == null) {
      return Container(
        color: AppColors.surfaceContainer,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.outline),
        ),
      );
    }
    return Image.memory(bytes, fit: BoxFit.cover);
  }

  String _formatDate(String? raw) {
    if (raw == null) return 'Completed';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'Completed';
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }
}
