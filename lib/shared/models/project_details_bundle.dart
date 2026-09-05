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
    this.visits = const [],
    this.cachedAt,
  });

  final ProjectModel project;
  final Map<int, bool> moduleDone;
  final List<Map<String, dynamic>> images;
  final List<MaterialLine> materials;
  final Map<String, dynamic>? plot;
  final String? ownerPhone;
  final List<Map<String, dynamic>> constructionStages;
  final List<Map<String, dynamic>> visits;
  final DateTime? cachedAt;

  bool isFresh([Duration ttl = const Duration(seconds: 45)]) {
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt!) < ttl;
  }
}
