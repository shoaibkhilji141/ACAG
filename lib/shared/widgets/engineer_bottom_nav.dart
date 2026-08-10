import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum EngineerNavItem { dashboard, projects, reports, profile }

/// Engineer bottom navigation with a center camera FAB (Stitch layout).
class EngineerBottomNav extends StatelessWidget {
  const EngineerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCameraTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCameraTap;

  static const _items = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    (icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Projects'),
    (icon: Icons.assessment_outlined, activeIcon: Icons.assessment, label: 'Reports'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  int _navIndexFor(int displayIndex) {
    return displayIndex < 2 ? displayIndex : displayIndex - 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeNavIndex = _navIndexFor(currentIndex);

    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      if (i == 2)
                        const Expanded(child: SizedBox())
                      else
                        Expanded(
                          child: _NavItem(
                            icon: _items[_navIndexFor(i)].icon,
                            activeIcon: _items[_navIndexFor(i)].activeIcon,
                            label: _items[_navIndexFor(i)].label,
                            selected: _navIndexFor(i) == activeNavIndex,
                            onTap: () => onTap(i),
                            theme: theme,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -20,
            child: _CameraFab(onTap: onCameraTap),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.secondary;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFab extends StatelessWidget {
  const _CameraFab({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: AppColors.primaryContainer.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      color: AppColors.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceLowest,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// Maps logical nav indices (0–3, skipping camera slot) to display indices.
extension EngineerNavIndex on EngineerNavItem {
  int get displayIndex => switch (this) {
        EngineerNavItem.dashboard => 0,
        EngineerNavItem.projects => 1,
        EngineerNavItem.reports => 3,
        EngineerNavItem.profile => 4,
      };
}
