import 'app_constants.dart';

/// Metadata for all 15 Stitch screens in exact required order.
class StitchScreenDef {
  const StitchScreenDef({
    required this.number,
    required this.title,
    required this.route,
    required this.moduleNumber,
    required this.moduleTitle,
    required this.stepInModule,
    required this.totalStepsInModule,
    this.nextRoute,
  });

  final int number;
  final String title;
  final String route;
  final String moduleNumber;
  final String moduleTitle;
  final int stepInModule;
  final int totalStepsInModule;
  final String? nextRoute;
}

const stitchScreens = <StitchScreenDef>[
  StitchScreenDef(
    number: 1,
    title: 'Plot Dimensions',
    route: AppRoutes.stitchPlotDimensions,
    moduleNumber: '01',
    moduleTitle: 'Planning & Elevation',
    stepInModule: 1,
    totalStepsInModule: 4,
    nextRoute: AppRoutes.stitchRoomRequirements,
  ),
  StitchScreenDef(
    number: 2,
    title: 'Room Requirements',
    route: AppRoutes.stitchRoomRequirements,
    moduleNumber: '01',
    moduleTitle: 'Planning & Elevation',
    stepInModule: 2,
    totalStepsInModule: 4,
    nextRoute: AppRoutes.stitchGeneratedFloorPlans,
  ),
  StitchScreenDef(
    number: 3,
    title: 'Generated Floor Plans',
    route: AppRoutes.stitchGeneratedFloorPlans,
    moduleNumber: '01',
    moduleTitle: 'Planning & Elevation',
    stepInModule: 3,
    totalStepsInModule: 4,
    nextRoute: AppRoutes.stitchElevationDesign,
  ),
  StitchScreenDef(
    number: 4,
    title: 'Elevation Design',
    route: AppRoutes.stitchElevationDesign,
    moduleNumber: '01',
    moduleTitle: 'Planning & Elevation',
    stepInModule: 4,
    totalStepsInModule: 4,
  ),
  StitchScreenDef(
    number: 5,
    title: 'Number of Stories',
    route: AppRoutes.stitchNumberOfStories,
    moduleNumber: '02',
    moduleTitle: 'Foundation & Structural',
    stepInModule: 1,
    totalStepsInModule: 4,
    nextRoute: AppRoutes.stitchSoilAnalysisDetails,
  ),
  StitchScreenDef(
    number: 6,
    title: 'Soil Analysis Details',
    route: AppRoutes.stitchSoilAnalysisDetails,
    moduleNumber: '02',
    moduleTitle: 'Foundation & Structural',
    stepInModule: 2,
    totalStepsInModule: 4,
    nextRoute: AppRoutes.stitchGeneratedFoundationDrawing,
  ),
  StitchScreenDef(
    number: 7,
    title: 'Generated Foundation Drawing',
    route: AppRoutes.stitchGeneratedFoundationDrawing,
    moduleNumber: '02',
    moduleTitle: 'Foundation & Structural',
    stepInModule: 3,
    totalStepsInModule: 4,
    nextRoute: AppRoutes.stitchStructuralFrameType,
  ),
  StitchScreenDef(
    number: 8,
    title: 'Structural Frame Type',
    route: AppRoutes.stitchStructuralFrameType,
    moduleNumber: '02',
    moduleTitle: 'Foundation & Structural',
    stepInModule: 4,
    totalStepsInModule: 4,
  ),
  StitchScreenDef(
    number: 9,
    title: 'Material Estimation & Costing',
    route: AppRoutes.stitchMaterialEstimation,
    moduleNumber: '03',
    moduleTitle: 'Material Estimation & Costing',
    stepInModule: 1,
    totalStepsInModule: 1,
  ),
  StitchScreenDef(
    number: 10,
    title: 'Stage Timeline',
    route: AppRoutes.stitchStageTimeline,
    moduleNumber: '04',
    moduleTitle: 'Construction Tracking & QA',
    stepInModule: 1,
    totalStepsInModule: 3,
    nextRoute: AppRoutes.stitchPhotoUpload,
  ),
  StitchScreenDef(
    number: 11,
    title: 'Photo Upload',
    route: AppRoutes.stitchPhotoUpload,
    moduleNumber: '04',
    moduleTitle: 'Construction Tracking & QA',
    stepInModule: 2,
    totalStepsInModule: 3,
    nextRoute: AppRoutes.stitchQualityAssessment,
  ),
  StitchScreenDef(
    number: 12,
    title: 'Quality Assessment',
    route: AppRoutes.stitchQualityAssessment,
    moduleNumber: '04',
    moduleTitle: 'Construction Tracking & QA',
    stepInModule: 3,
    totalStepsInModule: 3,
  ),
  StitchScreenDef(
    number: 13,
    title: 'Project Handover',
    route: AppRoutes.stitchProjectHandover,
    moduleNumber: '05',
    moduleTitle: 'Handover & HSE',
    stepInModule: 1,
    totalStepsInModule: 3,
  ),
  StitchScreenDef(
    number: 14,
    title: 'HSE Compliance',
    route: AppRoutes.stitchHseCompliance,
    moduleNumber: '05',
    moduleTitle: 'Handover & HSE',
    stepInModule: 2,
    totalStepsInModule: 3,
    nextRoute: AppRoutes.stitchCompletionCertificate,
  ),
  StitchScreenDef(
    number: 15,
    title: 'Completion Certificate',
    route: AppRoutes.stitchCompletionCertificate,
    moduleNumber: '05',
    moduleTitle: 'Handover & HSE',
    stepInModule: 3,
    totalStepsInModule: 3,
  ),
];

StitchScreenDef stitchScreenByRoute(String route) {
  return stitchScreens.firstWhere((s) => s.route == route);
}

List<StitchScreenDef> stitchScreensForModule(String moduleNumber) {
  return stitchScreens.where((s) => s.moduleNumber == moduleNumber).toList();
}

String? firstScreenRouteForModule(String moduleNumber) {
  final screens = stitchScreensForModule(moduleNumber);
  return screens.isEmpty ? null : screens.first.route;
}
