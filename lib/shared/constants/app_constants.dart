class AppConstants {
  static const appName = 'ACAG';
  static const appTagline = 'Apni Chhat Apna Ghar';
  static const orgLine = 'Government of Punjab';
  static const urbanUnit = 'The Urban Unit';

  /// Hardcoded demo credentials (frontend mock only).
  static const engineerEmail = 'engineer@gmail.com';
  static const ownerEmail = 'owner@gmail.com';
  static const demoPassword = '12345678';

  /// Resolves demo login to a role. Returns null when credentials are invalid.
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
