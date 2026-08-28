import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/project_list_tile.dart';
import '../../theme/app_theme.dart';

class AssignedProjectsScreen extends StatefulWidget {
  const AssignedProjectsScreen({super.key});

  @override
  State<AssignedProjectsScreen> createState() => _AssignedProjectsScreenState();
}

class _AssignedProjectsScreenState extends State<AssignedProjectsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ProjectStatus? _filter;
  List<ProjectModel> _projects = [];
  bool _loading = true;

  static const _filters = <(String, ProjectStatus?)>[
    ('All', null),
    ('Pending', ProjectStatus.pending),
    ('In Progress', ProjectStatus.inProgress),
    ('Completed', ProjectStatus.completed),
  ];

  @override
  void initState() {
    super.initState();
    final cached = ProjectService.cachedAssignedProjects;
    if (cached != null) {
      _projects = cached;
      _loading = false;
    }
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    final projects = await ProjectService.listAssignedProjects();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _loading = false;
    });
  }

  List<ProjectModel> get _filteredProjects {
    return _projects.where((p) {
      final matchesFilter = _filter == null || p.status == _filter;
      final q = _query.toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q) ||
          p.ownerName.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _openProject(ProjectModel project) async {
    ProjectService.prefetchDetails(project.id);
    await Navigator.of(context).pushNamed(
      AppRoutes.engineerProjectDetails,
      arguments: project,
    );
    if (mounted) await _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = _filteredProjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AcagAppBar(
        title: 'Assigned Projects',
        showBranding: false,
        notificationCount: 12,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search projects, owners, locations...',
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (label, status) = _filters[index];
                final selected = _filter == status;
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = status),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? AppColors.primary : AppColors.secondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading && projects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : projects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_outlined,
                              size: 48,
                              color: AppColors.outline.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No projects found',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: projects.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return ProjectListTile(
                              project: project,
                              onTap: () => _openProject(project),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
