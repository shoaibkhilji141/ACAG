import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/engineer_bottom_nav.dart';
import '../screens/assigned_projects_screen.dart';
import '../screens/engineer_dashboard_screen.dart';
import '../screens/engineer_profile_screen.dart';
import '../screens/engineer_reports_tab.dart';

class EngineerShell extends StatefulWidget {
  const EngineerShell({super.key});

  @override
  State<EngineerShell> createState() => _EngineerShellState();
}

class _EngineerShellState extends State<EngineerShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == 2) return; // Camera FAB slot
    setState(() => _currentIndex = index);
  }

  void _openCamera() {
    Navigator.of(context).pushNamed(
      AppRoutes.engineerCamera,
      arguments: MockData.primaryProject,
    );
  }

  void _goToProjects() {
    setState(() => _currentIndex = EngineerNavItem.projects.displayIndex);
  }

  int get _stackIndex => switch (_currentIndex) {
        0 => 0,
        1 => 1,
        3 => 2,
        4 => 3,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: [
          EngineerDashboardScreen(onNavigateToProjects: _goToProjects),
          const AssignedProjectsScreen(),
          const EngineerReportsTab(),
          const EngineerProfileScreen(),
        ],
      ),
      bottomNavigationBar: EngineerBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onCameraTap: _openCamera,
      ),
    );
  }
}
