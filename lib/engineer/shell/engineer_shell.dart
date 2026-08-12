import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/engineer_bottom_nav.dart';
import '../../theme/app_theme.dart';
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

  final _picker = ImagePicker();

  Future<void> _openCamera() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    try {
      final project = MockData.primaryProject;
      final base64 = await encodeFileToBase64(File(picked.path));
      await ProjectService.addProjectImageBase64(
        projectCodeOrId: project.id,
        imageBase64: base64,
        caption: 'Quick capture',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo saved to project images'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
