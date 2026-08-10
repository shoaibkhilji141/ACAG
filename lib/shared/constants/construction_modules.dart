import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'stitch_screens.dart';

/// Construction module metadata for the Project Details hub.
class ConstructionModuleInfo {
  const ConstructionModuleInfo({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.firstScreenRoute,
    required this.accentColor,
    required this.statusColor,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String firstScreenRoute;
  final Color accentColor;
  final Color statusColor;
}

const constructionModules = <ConstructionModuleInfo>[
  ConstructionModuleInfo(
    number: '01',
    title: 'Planning & Elevation',
    subtitle: 'Plot dimensions, rooms, floor plans & elevation',
    icon: Icons.architecture_outlined,
    route: AppRoutes.projectModule01,
    firstScreenRoute: AppRoutes.stitchPlotDimensions,
    accentColor: Color(0xFF1B7D51),
    statusColor: Color(0xFF1B7D51),
  ),
  ConstructionModuleInfo(
    number: '02',
    title: 'Foundation & Structural',
    subtitle: 'Stories, soil analysis & foundation drawings',
    icon: Icons.foundation_outlined,
    route: AppRoutes.projectModule02,
    firstScreenRoute: AppRoutes.stitchNumberOfStories,
    accentColor: Color(0xFFF5A623),
    statusColor: Color(0xFFF5A623),
  ),
  ConstructionModuleInfo(
    number: '03',
    title: 'Material Estimation',
    subtitle: 'Material quantities & cost breakdown',
    icon: Icons.inventory_2_outlined,
    route: AppRoutes.projectModule03,
    firstScreenRoute: AppRoutes.stitchMaterialEstimation,
    accentColor: Color(0xFF6B7280),
    statusColor: Color(0xFFD1D5DB),
  ),
  ConstructionModuleInfo(
    number: '04',
    title: 'Construction Tracking',
    subtitle: 'Stage timeline, photos & quality checks',
    icon: Icons.construction_outlined,
    route: AppRoutes.projectModule04,
    firstScreenRoute: AppRoutes.stitchStageTimeline,
    accentColor: Color(0xFF15693F),
    statusColor: Color(0xFFD1D5DB),
  ),
  ConstructionModuleInfo(
    number: '05',
    title: 'Handover & HSE',
    subtitle: 'Handover, HSE compliance & certificate',
    icon: Icons.verified_user_outlined,
    route: AppRoutes.projectModule05,
    firstScreenRoute: AppRoutes.stitchProjectHandover,
    accentColor: Color(0xFFDC2626),
    statusColor: Color(0xFFD1D5DB),
  ),
];

List<StitchScreenDef> screensForModule(String moduleNumber) =>
    stitchScreensForModule(moduleNumber);
