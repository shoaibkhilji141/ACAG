import 'package:flutter/material.dart';

import '../../shared/services/auth_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/owner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/owner_bottom_nav.dart';
import '../../theme/app_theme.dart';
import '../screens/my_project_screen.dart';
import '../screens/owner_dashboard_screen.dart';
import '../screens/owner_profile_screen.dart';
import '../screens/owner_reports_screen.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _currentIndex = 0;

  static const _screens = [
    OwnerDashboardScreen(),
    MyProjectScreen(),
    OwnerReportsScreen(),
    OwnerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AuthService.currentProfile();
    NotificationService.startPolling(
      interval: const Duration(seconds: 15),
    );
    // Prefetch project bundle / visits / reports / docs in background.
    ProjectService.prefetchOwnerHub().then((_) async {
      final project = await ProjectService.primaryOwnerProject();
      if (project == null) return;
      await Future.wait([
        OwnerService.listDocuments(project.id),
        OwnerService.listComplaints(project.id),
      ]);
    });
  }

  @override
  void dispose() {
    NotificationService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: OwnerBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
