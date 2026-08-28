import 'models.dart';

/// All project-details data loaded in one parallel Supabase round-trip.
class ProjectDetailsBundle {
  const ProjectDetailsBundle({
    required this.project,
    required this.moduleDone,
    required this.images,
    required this.materials,
    this.plot,
    this.ownerPhone,
    this.constructionStages = const [],
  });

  final ProjectModel project;
  final Map<int, bool> moduleDone;
  final List<Map<String, dynamic>> images;
  final List<MaterialLine> materials;
  final Map<String, dynamic>? plot;
  final String? ownerPhone;
  final List<Map<String, dynamic>> constructionStages;
}
