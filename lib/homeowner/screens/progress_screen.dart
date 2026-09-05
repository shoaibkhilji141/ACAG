import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_stages.dart';
import '../../shared/models/models.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/image_preview_dialog.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProjectModel? _project;
  List<Map<String, dynamic>> _stageRows = const [];
  bool _loading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_badge);
    _badge();
    _load();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_badge);
    super.dispose();
  }

  Future<void> _badge() async {
    final n = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = n);
  }

  Future<void> _load({bool force = false}) async {
    final project = await ProjectService.primaryOwnerProject();
    if (project == null) {
      if (mounted) setState(() { _loading = false; _project = null; });
      return;
    }

    final cached = ProjectService.getCachedBundle(project.id);
    if (!force && cached != null) {
      setState(() {
        _project = cached.project;
        _stageRows = cached.constructionStages;
        _loading = false;
      });
      if (cached.isFresh()) return;
    }

    final bundle = await ProjectService.fetchDetailsBundle(
      project.id,
      fallbackProject: project,
      forceRefresh: force,
    );
    if (!mounted) return;
    setState(() {
      _project = bundle.project;
      _stageRows = bundle.constructionStages;
      _loading = false;
    });
  }

  Map<int, Map<String, dynamic>> get _byStageNo {
    final map = <int, Map<String, dynamic>>{};
    for (final row in _stageRows) {
      final raw = row['stage_no'];
      final no = raw is num ? raw.toInt() : int.tryParse('$raw');
      if (no != null) map[no] = row;
    }
    return map;
  }

  void _openStage(int stageNo, Map<String, dynamic>? row) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _StageDetailSheet(
        stageNo: stageNo,
        project: _project!,
        row: row,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = _project;
    final byNo = _byStageNo;
    final completed = byNo.length;
    final progress = ConstructionStages.total == 0
        ? 0.0
        : (completed / ConstructionStages.total).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Construction Progress',
        showBranding: false,
        showBack: true,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : project == null
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.timeline_outlined,
                        message: 'No project linked for progress tracking.',
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      FluentCard(
                        child: Row(
                          children: [
                            ProgressRing(
                              progress: progress,
                              size: 100,
                              strokeWidth: 9,
                              centerSubtext: 'Stages',
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    project.id,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$completed of ${ConstructionStages.total} stages completed',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Stage Timeline'),
                      const SizedBox(height: 12),
                      FluentCard(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Column(
                          children: [
                            for (var i = 0;
                                i < ConstructionStages.stages.length;
                                i++)
                              _StageTimelineRow(
                                stageNo: i + 1,
                                title: ConstructionStages.stages[i],
                                row: byNo[i + 1],
                                isFirst: i == 0,
                                isLast:
                                    i == ConstructionStages.stages.length - 1,
                                previousCompleted: i > 0 && byNo.containsKey(i),
                                onTap: () => _openStage(i + 1, byNo[i + 1]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _StageTimelineRow extends StatelessWidget {
  const _StageTimelineRow({
    required this.stageNo,
    required this.title,
    required this.row,
    required this.isFirst,
    required this.isLast,
    required this.previousCompleted,
    required this.onTap,
  });

  final int stageNo;
  final String title;
  final Map<String, dynamic>? row;
  final bool isFirst;
  final bool isLast;
  final bool previousCompleted;
  final VoidCallback onTap;

  bool get completed => row != null;

  String get statusLabel => completed ? 'Completed' : 'Pending';

  String get dateLabel {
    final raw = row?['completed_at'] as String?;
    if (raw == null) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '—';
    return DateFormat('dd MMM yyyy').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  if (!isFirst)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: completed || previousCompleted
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: completed
                          ? AppColors.primaryContainer
                          : AppColors.surfaceLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: completed
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      completed ? Icons.check : Icons.schedule_outlined,
                      size: 14,
                      color: completed
                          ? AppColors.onPrimary
                          : AppColors.outline,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: completed
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$stageNo. $title',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: completed
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: completed
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          dateLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: completed
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (row?['description'] != null &&
                        (row!['description'] as String).trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        row!['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageDetailSheet extends StatefulWidget {
  const _StageDetailSheet({
    required this.stageNo,
    required this.project,
    required this.row,
  });

  final int stageNo;
  final ProjectModel project;
  final Map<String, dynamic>? row;

  @override
  State<_StageDetailSheet> createState() => _StageDetailSheetState();
}

class _StageDetailSheetState extends State<_StageDetailSheet> {
  List<String> _images = const [];
  bool _loadingImages = false;

  @override
  void initState() {
    super.initState();
    if (widget.row != null) _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _loadingImages = true);
    try {
      final full = await ProjectService.getConstructionStage(
        widget.project.id,
        widget.stageNo,
      );
      final imgs = ProjectService.stageImagesFromRow(full);
      if (mounted) {
        setState(() {
          _images = imgs;
          _loadingImages = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingImages = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = widget.row != null;
    final title = ConstructionStages.nameFor(widget.stageNo);
    final completedAt = widget.row?['completed_at'] as String?;
    final date = completedAt == null
        ? '—'
        : DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(completedAt).toLocal());
    final remarks = (widget.row?['description'] as String?)?.trim() ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Stage ${widget.stageNo}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(completed ? 'Completed' : 'Pending'),
                  backgroundColor: completed
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.outlineVariant.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: completed
                        ? AppColors.success
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Chip(
                  label: const Text('Approval: N/A'),
                  backgroundColor:
                      AppColors.outlineVariant.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _kv('Completion date', date),
            _kv('Start date', '—'),
            _kv('Engineer visit date', date == '—' ? '—' : date),
            _kv('Engineer remarks', remarks.isEmpty ? '—' : remarks),
            const SizedBox(height: 12),
            Text(
              'Photos',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (_loadingImages)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_images.isEmpty)
              Text(
                completed ? 'No photos attached.' : 'Complete this stage to see photos.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final bytes = decodeBase64Image(_images[i]);
                    return GestureDetector(
                      onTap: () => showBase64ImagePreview(
                        context,
                        imageBase64: _images[i],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: bytes == null
                            ? Container(
                                width: 100,
                                color: AppColors.surfaceContainer,
                                child: const Icon(Icons.broken_image_outlined),
                              )
                            : Image.memory(
                                bytes,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
