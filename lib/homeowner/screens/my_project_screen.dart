import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_modules.dart';
import '../../shared/constants/construction_stages.dart';
import '../../shared/models/models.dart';
import '../../shared/models/project_details_bundle.dart';
import '../../shared/services/map_launch_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/image_preview_dialog.dart';
import '../../theme/app_theme.dart';

/// Owner project hub — mirrors engineer Project Details layout (read-only).
class MyProjectScreen extends StatefulWidget {
  const MyProjectScreen({super.key});

  @override
  State<MyProjectScreen> createState() => _MyProjectScreenState();
}

class _MyProjectScreenState extends State<MyProjectScreen> {
  int _selectedTab = 0;
  ProjectModel? _project;
  Map<int, bool> _moduleDone = {};
  List<Map<String, dynamic>> _images = [];
  List<MaterialLine> _materials = [];
  Map<String, dynamic>? _plot;
  List<Map<String, dynamic>> _visits = [];
  bool _loadingMeta = true;
  int _unread = 0;

  List<String> get _tabs => [
        'Details',
        'Images (${_images.length})',
        'Materials',
      ];

  double get _moduleProgress => ProjectService.progressFromModules(_moduleDone);

  String get _modulePhase => ProjectService.phaseFromModules(_moduleDone);

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_loadBadge);
    _loadBadge();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_loadBadge);
    super.dispose();
  }

  Future<void> _loadBadge() async {
    final count = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  Future<void> _bootstrap() async {
    final cachedProjects = ProjectService.cachedOwnerProjects;
    final code = (cachedProjects != null && cachedProjects.isNotEmpty)
        ? cachedProjects.first.id
        : null;
    if (code != null) {
      final cached = ProjectService.getCachedBundle(code);
      if (cached != null) {
        _applyBundle(cached, showLoading: false);
      }
    }
    await _refreshMeta(silent: code != null);
  }

  void _applyBundle(ProjectDetailsBundle bundle, {required bool showLoading}) {
    setState(() {
      _project = bundle.project;
      _moduleDone = bundle.moduleDone;
      _images = bundle.images;
      _materials = bundle.materials;
      _plot = bundle.plot;
      _visits = bundle.visits;
      _loadingMeta = showLoading;
    });
  }

  Future<void> _refreshMeta({bool silent = false}) async {
    if (!silent) setState(() => _loadingMeta = true);
    try {
      final project = await ProjectService.primaryOwnerProject();
      if (project == null) {
        if (!mounted) return;
        setState(() {
          _project = null;
          _loadingMeta = false;
        });
        return;
      }
      final bundle = await ProjectService.fetchDetailsBundle(
        project.id,
        fallbackProject: project,
      );
      if (!mounted) return;
      _applyBundle(bundle, showLoading: false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMeta = false);
    }
  }

  Future<void> _viewOnMap() async {
    final project = _project;
    if (project == null) return;
    try {
      await MapLaunchService.openProjectLocation(project);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = _project;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Project Details',
        showBranding: false,
        showBack: ModalRoute.of(context)?.settings.name == AppRoutes.ownerProject,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: project == null && _loadingMeta
          ? const Center(child: CircularProgressIndicator())
          : project == null
              ? const EmptyPlaceholder(
                  icon: Icons.home_work_outlined,
                  message: 'No project is linked to this account.',
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await ProjectService.primaryOwnerProject(
                            forceRefresh: true,
                          );
                          await ProjectService.fetchDetailsBundle(
                            project.id,
                            fallbackProject: project,
                            forceRefresh: true,
                          );
                          await _refreshMeta();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OwnerProjectHero(project: project),
                              const SizedBox(height: 20),
                              _ProgressOverview(
                                phase: _modulePhase,
                                progress: _moduleProgress,
                              ),
                              const SizedBox(height: 20),
                              _TabBar(
                                tabs: _tabs,
                                selected: _selectedTab,
                                onSelected: (i) =>
                                    setState(() => _selectedTab = i),
                              ),
                              const SizedBox(height: 16),
                              if (_selectedTab == 0)
                                _DetailsTab(project: project, plot: _plot),
                              if (_selectedTab == 1)
                                _ImagesTab(
                                  images: _images,
                                  loading: _loadingMeta,
                                ),
                              if (_selectedTab == 2)
                                _MaterialsTab(
                                  materials: _materials,
                                  loading: _loadingMeta,
                                ),
                              const SizedBox(height: 20),
                              Text(
                                'Track Construction',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _ActionRow(
                                icon: Icons.timeline_outlined,
                                title: 'Construction Progress',
                                subtitle:
                                    'Stage timeline (${ConstructionStages.total} stages)',
                                color: const Color(0xFF1B7D51),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ownerProgress,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.photo_library_outlined,
                                title: 'Site Photographs',
                                subtitle: '${_images.length} photos uploaded',
                                color: const Color(0xFFF5A623),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ownerPhotos,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.engineering_outlined,
                                title: 'Engineer Visits',
                                subtitle: _visits.isEmpty
                                    ? 'No visits recorded yet'
                                    : '${_visits.length} visit(s) · Next: ${project.nextInspection}',
                                color: AppColors.primary,
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ownerVisits,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.folder_outlined,
                                title: 'Documents',
                                subtitle: 'CNIC, plans, NOC & certificates',
                                color: const Color(0xFF0F766E),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ownerReports,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.report_problem_outlined,
                                title: 'Complaints / Issues',
                                subtitle: 'Submit and track site issues',
                                color: const Color(0xFFDC2626),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ownerComplaints,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.rate_review_outlined,
                                title: 'Feedback & Rating',
                                subtitle: 'Rate your ACAG experience',
                                color: const Color(0xFF7C3AED),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.ownerFeedback,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Modules Status',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (final module in constructionModules) ...[
                                _ModuleStatusRow(
                                  module: module,
                                  completed: _moduleDone[
                                          int.parse(module.number)] ==
                                      true,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _viewOnMap,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text(
                            'View on Map',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}


class _OwnerProjectHero extends StatelessWidget {
  const _OwnerProjectHero({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 96,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.apartment_outlined,
              size: 48,
              color: Color(0xFF78350F),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.id,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Engineer: ${project.engineerName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.locationLine,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                project.statusLabel.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetaBlock(
                icon: Icons.layers_outlined,
                label: 'Floors',
                value: project.storiesLabel ?? '—',
              ),
            ),
            Expanded(
              child: _MetaBlock(
                icon: Icons.straighten_outlined,
                label: 'Plot',
                value: project.plotSizeLabel ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _DateChip(label: 'Start', value: project.startDateLabel ?? '—'),
            _DateChip(
              label: 'Expected',
              value: project.estimatedCompletionLabel ?? '—',
            ),
            _DateChip(label: 'Next Visit', value: project.nextInspection),
          ],
        ),
      ],
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today_outlined,
            size: 14, color: AppColors.outline),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({
    required this.phase,
    required this.progress,
  });

  final String phase;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Overview',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  phase,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Text(
              '$percent%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
            color: AppColors.primaryContainer,
          ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            ChoiceChip(
              label: Text(tabs[i]),
              selected: selected == i,
              onSelected: (_) => onSelected(i),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: selected == i
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: selected == i ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected == i
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              backgroundColor: AppColors.surfaceLowest,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.project, this.plot});

  final ProjectModel project;
  final Map<String, dynamic>? plot;

  @override
  Widget build(BuildContext context) {
    final plotLabel = project.plotSizeLabel ??
        (plot == null
            ? '—'
            : '${plot!['length']}×${plot!['width']} ${plot!['unit']}');

    return FluentCard(
      child: Column(
        children: [
          _InfoLine(label: 'Project ID', value: project.id),
          _divider(),
          _InfoLine(label: 'Title', value: project.title),
          _divider(),
          _InfoLine(label: 'Address', value: project.address),
          _divider(),
          _InfoLine(
            label: 'City / District / Tehsil',
            value: [
              if (project.city.trim().isNotEmpty) project.city,
              if (project.district?.trim().isNotEmpty == true)
                project.district!,
              if (project.tehsil?.trim().isNotEmpty == true) project.tehsil!,
            ].join(' / ').ifEmptyDash,
          ),
          _divider(),
          _InfoLine(label: 'Plot size', value: plotLabel),
          _divider(),
          _InfoLine(
            label: 'Covered area',
            value: project.coveredAreaLabel ?? '—',
          ),
          _divider(),
          _InfoLine(
            label: 'Floors',
            value: project.storiesLabel ?? '—',
          ),
          _divider(),
          _InfoLine(
            label: 'Start date',
            value: project.startDateLabel ?? '—',
          ),
          _divider(),
          _InfoLine(
            label: 'Expected completion',
            value: project.estimatedCompletionLabel ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 20,
        color: AppColors.outlineVariant.withValues(alpha: 0.35),
      );
}

extension on String {
  String get ifEmptyDash => trim().isEmpty ? '—' : this;
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagesTab extends StatelessWidget {
  const _ImagesTab({required this.images, required this.loading});

  final List<Map<String, dynamic>> images;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading && images.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (images.isEmpty) {
      return FluentCard(
        child: Text(
          'No site photos yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length.clamp(0, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final image = images[index];
        final bytes = decodeBase64Image(image['image_base64'] as String?);
        final caption = image['caption'] as String?;
        return GestureDetector(
          onTap: () => showBase64ImagePreview(
            context,
            imageBase64: image['image_base64'] as String?,
            caption: caption,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bytes == null
                ? Container(
                    color: AppColors.surfaceContainer,
                    child: const Icon(Icons.broken_image_outlined),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(bytes, fit: BoxFit.cover),
                      if (caption != null && caption.trim().isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.black54,
                            child: Text(
                              caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  const _MaterialsTab({required this.materials, required this.loading});

  final List<MaterialLine> materials;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading && materials.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (materials.isEmpty) {
      return FluentCard(
        child: Text(
          'Material estimates not available yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }
    return FluentCard(
      child: Column(
        children: [
          for (var i = 0; i < materials.length; i++) ...[
            if (i > 0)
              Divider(
                height: 18,
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    materials[i].name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${materials[i].qty} ${materials[i].unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluentCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }
}

class _ModuleStatusRow extends StatelessWidget {
  const _ModuleStatusRow({
    required this.module,
    required this.completed,
  });

  final ConstructionModuleInfo module;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluentCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: module.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(module.icon, color: module.accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module ${module.number} — ${module.title}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  module.subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.outlineVariant.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              completed ? 'Done' : 'Pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: completed ? AppColors.success : AppColors.outline,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
