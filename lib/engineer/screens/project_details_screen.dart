import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/construction_modules.dart';
import '../../shared/models/models.dart';
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

  static const _tabs = ['Details', 'Images (8)', 'AI Status', 'Materials'];
  static const _progressSteps = [
    _ProgressStep('DPC', done: true),
    _ProgressStep('Brick Work', done: true, active: true),
    _ProgressStep('Roof', done: false),
    _ProgressStep('Plaster', done: false),
    _ProgressStep('Finishing', done: false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Project Details'),
        centerTitle: true,
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProjectHero(project: project),
                  const SizedBox(height: 20),
                  _ProgressOverview(
                    phase: project.phase,
                    progress: project.progress,
                  ),
                  const SizedBox(height: 20),
                  _TabBar(
                    tabs: _tabs,
                    selected: _selectedTab,
                    onSelected: (i) => setState(() => _selectedTab = i),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedTab == 0) _DetailsTab(project: project),
                  if (_selectedTab == 1) _PlaceholderTab(label: 'Project images'),
                  if (_selectedTab == 2) _PlaceholderTab(label: 'AI validation status'),
                  if (_selectedTab == 3) _PlaceholderTab(label: 'Materials overview'),
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
                      onTap: () => Navigator.of(context).pushNamed(
                        module.firstScreenRoute,
                        arguments: project,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
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
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.engineerGps,
                      arguments: project,
                    ),
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
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.outline),
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
    return name.substring(0, 2).toUpperCase();
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
                    color: _ProjectDetailsScreenState._progressSteps[i].done
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.4),
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
  const _ProgressStep(this.label, {this.done = false, this.active = false});

  final String label;
  final bool done;
  final bool active;
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
            color: step.done ? AppColors.primary : AppColors.surfaceLowest,
            shape: BoxShape.circle,
            border: Border.all(
              color: step.done
                  ? AppColors.primary
                  : AppColors.outlineVariant,
              width: 2,
            ),
          ),
          child: step.done
              ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: step.active ? FontWeight.w700 : FontWeight.w500,
            color: step.active || step.done
                ? AppColors.primary
                : AppColors.outline,
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
  const _DetailsTab({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow(label: 'Plot Size', value: '5 Marla'),
        _DetailRow(label: 'Construction Area', value: '1,250 Sq.ft'),
        _DetailRow(label: 'Estimated Completion', value: '10 Sep 2025'),
        _DetailRow(label: 'Assigned Date', value: '10 Apr 2025'),
        _DetailRow(label: 'Last Inspection', value: project.nextInspection),
      ],
    );
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
    required this.onTap,
  });

  final ConstructionModuleInfo module;
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
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: module.statusColor,
                  shape: BoxShape.circle,
                ),
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
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Re-export for backward compatibility with engineer workflow screens.
ProjectModel projectFromRoute(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  return args is ProjectModel ? args : MockData.primaryProject;
}
