import 'package:flutter/material.dart';

import '../engineer/screens/ai_validation_screen.dart';
import '../engineer/screens/assigned_projects_screen.dart';
import '../engineer/screens/camera_screen.dart';
import '../engineer/screens/gps_verification_screen.dart';
import '../engineer/screens/inspection_report_screen.dart';
import '../engineer/screens/login_screen.dart';
import '../engineer/screens/project_details_screen.dart';
import '../engineer/screens/signup_screen.dart';
import '../engineer/screens/splash_screen.dart';
import '../engineer/screens/upload_progress_screen.dart';
import '../engineer/shell/engineer_shell.dart';
import '../homeowner/screens/feedback_screen.dart';
import '../homeowner/screens/materials_screen.dart';
import '../homeowner/screens/my_project_screen.dart';
import '../homeowner/screens/notifications_screen.dart';
import '../homeowner/screens/owner_reports_screen.dart';
import '../homeowner/screens/photos_screen.dart';
import '../homeowner/screens/progress_screen.dart';
import '../homeowner/shell/owner_shell.dart';
import '../shared/constants/app_constants.dart';
import '../shared/constants/construction_modules.dart';
import '../shared/screens/construction_module_screen.dart';
import '../modules/module_01/plot_dimensions_screen.dart';
import '../modules/module_01/room_requirements_screen.dart';
import '../modules/module_01/generated_floor_plans_screen.dart';
import '../modules/module_01/elevation_design_screen.dart';
import '../modules/module_02/number_of_stories_screen.dart';
import '../modules/module_02/soil_analysis_details_screen.dart';
import '../modules/module_02/generated_foundation_drawing_screen.dart';
import '../modules/module_02/structural_frame_type_screen.dart';
import '../modules/module_03/material_estimation_screen.dart';
import '../modules/module_04/stage_timeline_screen.dart';
import '../modules/module_04/photo_upload_screen.dart';
import '../modules/module_04/quality_assessment_screen.dart';
import '../modules/module_05/project_handover_screen.dart';
import '../modules/module_05/hse_compliance_screen.dart';
import '../modules/module_05/completion_certificate_screen.dart';
import '../theme/app_theme.dart';

class AcagApp extends StatelessWidget {
  const AcagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appName} — Construction Validation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.engineerShell: (_) => const EngineerShell(),
        AppRoutes.engineerProjects: (_) => const AssignedProjectsScreen(),
        AppRoutes.engineerProjectDetails: (_) => const ProjectDetailsScreen(),
        AppRoutes.engineerGps: (_) => const GpsVerificationScreen(),
        AppRoutes.engineerUpload: (_) => const UploadProgressScreen(),
        AppRoutes.engineerCamera: (_) => const CameraScreen(),
        AppRoutes.engineerAi: (_) => const AiValidationScreen(),
        AppRoutes.engineerReport: (_) => const InspectionReportScreen(),
        AppRoutes.projectModule01: (_) =>
            ConstructionModuleScreen(module: constructionModules[0]),
        AppRoutes.projectModule02: (_) =>
            ConstructionModuleScreen(module: constructionModules[1]),
        AppRoutes.projectModule03: (_) =>
            ConstructionModuleScreen(module: constructionModules[2]),
        AppRoutes.projectModule04: (_) =>
            ConstructionModuleScreen(module: constructionModules[3]),
        AppRoutes.projectModule05: (_) =>
            ConstructionModuleScreen(module: constructionModules[4]),
        AppRoutes.stitchPlotDimensions: (_) => const PlotDimensionsScreen(),
        AppRoutes.stitchRoomRequirements: (_) =>
            const RoomRequirementsScreen(),
        AppRoutes.stitchGeneratedFloorPlans: (_) =>
            const GeneratedFloorPlansScreen(),
        AppRoutes.stitchElevationDesign: (_) => const ElevationDesignScreen(),
        AppRoutes.stitchNumberOfStories: (_) => const NumberOfStoriesScreen(),
        AppRoutes.stitchSoilAnalysisDetails: (_) =>
            const SoilAnalysisDetailsScreen(),
        AppRoutes.stitchGeneratedFoundationDrawing: (_) =>
            const GeneratedFoundationDrawingScreen(),
        AppRoutes.stitchStructuralFrameType: (_) =>
            const StructuralFrameTypeScreen(),
        AppRoutes.stitchMaterialEstimation: (_) =>
            const MaterialEstimationScreen(),
        AppRoutes.stitchStageTimeline: (_) => const StageTimelineScreen(),
        AppRoutes.stitchPhotoUpload: (_) => const PhotoUploadScreen(),
        AppRoutes.stitchQualityAssessment: (_) =>
            const QualityAssessmentScreen(),
        AppRoutes.stitchProjectHandover: (_) => const ProjectHandoverScreen(),
        AppRoutes.stitchHseCompliance: (_) => const HseComplianceScreen(),
        AppRoutes.stitchCompletionCertificate: (_) =>
            const CompletionCertificateScreen(),
        AppRoutes.ownerShell: (_) => const OwnerShell(),
        AppRoutes.ownerProject: (_) => const MyProjectScreen(),
        AppRoutes.ownerProgress: (_) => const ProgressScreen(),
        AppRoutes.ownerPhotos: (_) => const PhotosScreen(),
        AppRoutes.ownerMaterials: (_) => const MaterialsScreen(),
        AppRoutes.ownerReports: (_) => const OwnerReportsScreen(),
        AppRoutes.ownerNotifications: (_) => const NotificationsScreen(),
        AppRoutes.ownerFeedback: (_) => const FeedbackScreen(),
      },
    );
  }
}
