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
