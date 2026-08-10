class AppConstants {
  static const appName = 'ACAG';
  static const appTagline = 'Apni Chhat Apna Ghar';
  static const orgLine = 'Government of Punjab';
  static const urbanUnit = 'The Urban Unit';

  /// Seeded demo accounts in Supabase (for reference / tests).
  static const engineerEmail = 'shoaibkhilji141@gmail.com';
  static const ownerEmail = 'ali.raza.owner@gmail.com';
  static const demoPassword = '12345678';

  /// Local fallback resolver for unit tests / offline demo only.
  static UserRole? resolveDemoRole(String email, String password) {
    final normalized = email.trim().toLowerCase();
    if (password != demoPassword) return null;
    if (normalized == engineerEmail) return UserRole.engineer;
    if (normalized == ownerEmail) return UserRole.owner;
    return null;
  }

  static String routeForRole(UserRole role) => switch (role) {
        UserRole.engineer => AppRoutes.engineerShell,
        UserRole.owner => AppRoutes.ownerShell,
      };
}

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';

  static const engineerShell = '/engineer';
  static const engineerProjects = '/engineer/projects';
  static const engineerProjectDetails = '/engineer/project-details';
  static const engineerGps = '/engineer/gps';
  static const engineerUpload = '/engineer/upload';
  static const engineerCamera = '/engineer/camera';
  static const engineerAi = '/engineer/ai-validation';
  static const engineerReport = '/engineer/report';
  static const engineerProfile = '/engineer/profile';
  static const projectModule01 = '/project/module-01';
  static const projectModule02 = '/project/module-02';
  static const projectModule03 = '/project/module-03';
  static const projectModule04 = '/project/module-04';
  static const projectModule05 = '/project/module-05';

  static const stitchPlotDimensions = '/stitch/01-plot-dimensions';
  static const stitchRoomRequirements = '/stitch/02-room-requirements';
  static const stitchGeneratedFloorPlans = '/stitch/03-generated-floor-plans';
  static const stitchElevationDesign = '/stitch/04-elevation-design';
  static const stitchNumberOfStories = '/stitch/05-number-of-stories';
  static const stitchSoilAnalysisDetails = '/stitch/06-soil-analysis-details';
  static const stitchGeneratedFoundationDrawing =
      '/stitch/07-generated-foundation-drawing';
  static const stitchStructuralFrameType = '/stitch/08-structural-frame-type';
  static const stitchMaterialEstimation = '/stitch/09-material-estimation';
  static const stitchStageTimeline = '/stitch/10-stage-timeline';
  static const stitchPhotoUpload = '/stitch/11-photo-upload';
  static const stitchQualityAssessment = '/stitch/12-quality-assessment';
  static const stitchProjectHandover = '/stitch/13-project-handover';
  static const stitchHseCompliance = '/stitch/14-hse-compliance';
  static const stitchCompletionCertificate = '/stitch/15-completion-certificate';

  static const ownerShell = '/owner';
  static const ownerProject = '/owner/project';
  static const ownerProgress = '/owner/progress';
  static const ownerPhotos = '/owner/photos';
  static const ownerMaterials = '/owner/materials';
  static const ownerReports = '/owner/reports';
  static const ownerNotifications = '/owner/notifications';
  static const ownerFeedback = '/owner/feedback';
  static const ownerProfile = '/owner/profile';
}

enum UserRole { engineer, owner }
