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
  bool _hasProject = true;

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
    _resolveProjectAccess();
    // Prefetch project bundle / visits / reports / docs in background.
    ProjectService.prefetchOwnerHub().then((_) async {
      final project = await ProjectService.primaryOwnerProject();
      if (!mounted) return;
      _applyProjectAccess(project != null);
      if (project == null) return;
      await Future.wait([
        OwnerService.listDocuments(project.id),
        OwnerService.listComplaints(project.id),
      ]);
    });
  }

  Future<void> _resolveProjectAccess() async {
    final project = await ProjectService.primaryOwnerProject();
    if (!mounted) return;
    _applyProjectAccess(project != null);
  }

  void _applyProjectAccess(bool hasProject) {
    setState(() {
      _hasProject = hasProject;
      if (!hasProject && (_currentIndex == 0 || _currentIndex == 2)) {
        _currentIndex = 1;
      }
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
        hasProject: _hasProject,
        onTap: (index) {
          final locked = !_hasProject && (index == 0 || index == 2);
          if (locked) return;
          setState(() => _currentIndex = index);
          if (!_hasProject) _resolveProjectAccess();
        },
      ),
    );
  }
}
