import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_modules.dart';
import '../../shared/models/models.dart';
import '../../shared/services/map_launch_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/services/share_download_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  int _selectedTab = 0;
  Map<int, bool> _moduleDone = {};
  List<Map<String, dynamic>> _images = [];
  List<MaterialLine> _materials = [];
  Map<String, dynamic>? _plot;
  bool _loadingMeta = true;

  static const _progressSteps = [
    _ProgressStep('DPC'),
    _ProgressStep('Brick Work'),
    _ProgressStep('Roof'),
    _ProgressStep('Plaster'),
    _ProgressStep('Finishing'),
  ];

  ProjectModel get _project {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is ProjectModel ? args : MockData.primaryProject;
  }

  List<String> get _tabs => [
        'Details',
        'Images (${_images.length})',
        'AI Status',
        'Materials',
      ];

  double get _moduleProgress => ProjectService.progressFromModules(_moduleDone);

  String get _modulePhase => ProjectService.phaseFromModules(_moduleDone);

  @override
  void initState() {
    super.initState();
    ProjectService.moduleCompletionVersion.addListener(_onModuleCompletion);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshMeta());
  }

  @override
  void dispose() {
    ProjectService.moduleCompletionVersion.removeListener(_onModuleCompletion);
    super.dispose();
  }

  void _onModuleCompletion() {
    if (mounted) _refreshMeta();
  }

  Future<void> _refreshMeta() async {
    final project = _project;
    setState(() => _loadingMeta = true);
    try {
      final done = await ProjectService.getModuleCompletionMap(project.id);
      final images = await ProjectService.listProjectImages(project.id);
      final materials = await ProjectService.getMaterialLines(project.id);
      final plot = await ProjectService.getPlotDimensions(project.id);
      if (!mounted) return;
      setState(() {
        _moduleDone = done;
        _images = images;
        _materials = materials;
        _plot = plot;
        _loadingMeta = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMeta = false);
    }
  }

  Future<void> _shareProject() async {
    await ShareDownloadService.shareProjectDetails(_project);
  }

  Future<void> _captureProjectImage() async {
    final picker = ImagePicker();
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

    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      final base64 = await encodeFileToBase64(File(picked.path));
      await ProjectService.addProjectImageBase64(
        projectCodeOrId: _project.id,
        imageBase64: base64,
        caption: 'Project photo',
      );
      await _refreshMeta();
      if (!mounted) return;
      setState(() => _selectedTab = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image added to project')),
      );
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

  Future<void> _openModule(ConstructionModuleInfo module) async {
    await Navigator.of(context).pushNamed(
      module.firstScreenRoute,
      arguments: _project,
    );
    if (mounted) await _refreshMeta();
  }

  Future<void> _viewOnMap() async {
    try {
      await MapLaunchService.openProjectLocation(_project);
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
      appBar: AppBar(
        title: const Text('Project Details'),
        centerTitle: true,
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Add photo',
            icon: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
            onPressed: _captureProjectImage,
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: _shareProject,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMeta,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProjectHero(project: project),
                    const SizedBox(height: 20),
                    _ProgressOverview(
                      phase: _modulePhase,
                      progress: _moduleProgress,
                    ),
                    const SizedBox(height: 20),
                    _TabBar(
                      tabs: _tabs,
                      selected: _selectedTab,
                      onSelected: (i) => setState(() => _selectedTab = i),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedTab == 0)
                      _DetailsTab(project: project, plot: _plot),
                    if (_selectedTab == 1)
                      _ImagesTab(
                        images: _images,
                        loading: _loadingMeta,
                        onAdd: _captureProjectImage,
                      ),
                    if (_selectedTab == 2)
                      const _PlaceholderTab(label: 'AI validation status'),
                    if (_selectedTab == 3)
                      _MaterialsTab(
                        materials: _materials,
                        loading: _loadingMeta,
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Construction Modules',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final module in constructionModules) ...[
                      _ModuleRow(
                        module: module,
                        completed: _moduleDone[int.parse(module.number)] == true,
                        onTap: () => _openModule(module),
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
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Start Inspection',
                  icon: Icons.arrow_forward,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.engineerGps,
                    arguments: project,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _viewOnMap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View on Map',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

class _ImagesTab extends StatelessWidget {
  const _ImagesTab({
    required this.images,
    required this.loading,
    required this.onAdd,
  });

  final List<Map<String, dynamic>> images;
  final bool loading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (loading && images.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (images.isEmpty) {
      return FluentCard(
        child: Column(
          children: [
            const Icon(Icons.image_not_supported_outlined, color: AppColors.outline),
            const SizedBox(height: 8),
            Text(
              'No images yet (0)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Add Photo'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final bytes = decodeBase64Image(images[index]['image_base64'] as String?);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: bytes == null
              ? Container(
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.broken_image_outlined),
                )
              : Image.memory(bytes, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _ProjectHero extends StatelessWidget {
  const _ProjectHero({required this.project});

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
                    'House Owner: ${project.ownerName}',
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
                          '${project.address}, ${project.city}',
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
                color: const Color(0xFFFDF6E7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF5D0A0)),
              ),
              child: Text(
                'PENDING INSPECTION',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFF5A623),
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.phone_outlined, size: 18),
          label: const Text('Contact Owner'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetaBlock(
                icon: _Avatar(initials: _initials(project.engineerName)),
                label: 'Assigned To',
                value: 'Engr. ${_shortName(project.engineerName)}',
              ),
            ),
            Expanded(
              child: _MetaBlock(
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.home_work_outlined, size: 16),
                ),
                label: 'Project Type',
                value: 'Single Story',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.outline),
            const SizedBox(width: 6),
            Text(
              'Start Date',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '10 Apr 2025',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  static String _shortName(String name) {
    final parts = name.split(' ');
    return parts.length > 1 ? parts.last : name;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        icon,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'View Timeline',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.35),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < _ProjectDetailsScreenState._progressSteps.length; i++) ...[
              Expanded(
                child: _StepNode(
                  step: _ProjectDetailsScreenState._progressSteps[i],
                ),
              ),
              if (i < _ProjectDetailsScreenState._progressSteps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProgressStep {
  const _ProgressStep(this.label);

  final String label;
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.step});

  final _ProgressStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: AppColors.outline,
          ),
          textAlign: TextAlign.center,
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
    final theme = Theme.of(context);

    return Row(
      children: List.generate(tabs.length, (i) {
        final isSelected = i == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.project, this.plot});

  final ProjectModel project;
  final Map<String, dynamic>? plot;

  @override
  Widget build(BuildContext context) {
    final length = plot?['length'];
    final width = plot?['width'];
    final unit = plot?['unit'] as String?;
    final area = plot?['total_area'];

    final plotSize = (length != null && width != null && unit != null)
        ? '${_num(length)} × ${_num(width)} $unit'
        : '—';
    final constructionArea = area != null ? '${_num(area)} Sq.ft' : '—';

    return Column(
      children: [
        _DetailRow(label: 'Plot Size', value: plotSize),
        _DetailRow(label: 'Construction Area', value: constructionArea),
        _DetailRow(label: 'Address', value: '${project.address}, ${project.city}'),
        _DetailRow(label: 'Owner', value: project.ownerName),
        _DetailRow(label: 'Engineer', value: project.engineerName),
      ],
    );
  }

  static String _num(dynamic v) {
    if (v is num) {
      return v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
    }
    return '$v';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  const _MaterialsTab({
    required this.materials,
    required this.loading,
  });

  final List<MaterialLine> materials;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading && materials.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (materials.isEmpty) {
      return FluentCard(
        child: Text(
          'No materials saved yet. Complete Material Estimation module.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return FluentCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          for (var i = 0; i < materials.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materials[i].name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          materials[i].unit,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    materials[i].qty,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (i < materials.length - 1)
              Divider(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FluentCard(
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.module,
    required this.completed,
    required this.onTap,
  });

  final ConstructionModuleInfo module;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surfaceLowest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.primary
                      : module.statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed ? AppColors.primary : module.statusColor,
                  ),
                ),
                child: completed
                    ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Module ${module.number}: ${module.title}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                completed ? Icons.check_circle : Icons.chevron_right,
                color: completed ? AppColors.primary : AppColors.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ProjectModel projectFromRoute(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  return args is ProjectModel ? args : MockData.primaryProject;
}
