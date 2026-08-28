import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/mock_data.dart';

/// Route arguments for stitch / module flows (extends plain [ProjectModel]).
class StitchRouteArgs {
  const StitchRouteArgs({
    required this.project,
    this.stageNo,
    this.photoPath,
    this.photoPaths = const [],
    this.description,
  });

  final ProjectModel project;
  final int? stageNo;
  final String? photoPath;
  final List<String> photoPaths;
  final String? description;

  List<String> get effectivePhotoPaths {
    if (photoPaths.isNotEmpty) return photoPaths;
    if (photoPath != null && photoPath!.isNotEmpty) return [photoPath!];
    return const [];
  }

  StitchRouteArgs copyWith({
    ProjectModel? project,
    int? stageNo,
    String? photoPath,
    List<String>? photoPaths,
    String? description,
  }) {
    return StitchRouteArgs(
      project: project ?? this.project,
      stageNo: stageNo ?? this.stageNo,
      photoPath: photoPath ?? this.photoPath,
      photoPaths: photoPaths ?? this.photoPaths,
      description: description ?? this.description,
    );
  }
}

Object? routeArgumentsFromContext(BuildContext context) {
  return ModalRoute.of(context)?.settings.arguments;
}

StitchRouteArgs stitchArgsFromRoute(BuildContext context) {
  final args = routeArgumentsFromContext(context);
  if (args is StitchRouteArgs) return args;
  if (args is ProjectModel) return StitchRouteArgs(project: args);
  return StitchRouteArgs(project: MockData.primaryProject);
}

ProjectModel projectFromRoute(BuildContext context) {
  return stitchArgsFromRoute(context).project;
}

int? stageNoFromRoute(BuildContext context) {
  return stitchArgsFromRoute(context).stageNo;
}
