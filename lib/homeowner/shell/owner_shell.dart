import 'package:flutter/material.dart';

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
