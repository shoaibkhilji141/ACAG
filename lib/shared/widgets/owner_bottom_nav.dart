import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum OwnerNavItem { dashboard, myProject, reports, profile }

/// Owner bottom navigation — same visual language as engineer nav (no camera FAB).
class OwnerBottomNav extends StatelessWidget {
  const OwnerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard'
    ),
    (
      icon: Icons.home_work_outlined,
      activeIcon: Icons.home_work,
      label: 'My Project'
    ),
    (
      icon: Icons.assessment_outlined,
      activeIcon: Icons.assessment,
      label: 'Reports'
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _items[i].icon,
                    activeIcon: _items[i].activeIcon,
                    label: _items[i].label,
                    selected: currentIndex == i,
                    onTap: () => onTap(i),
                    theme: theme,
                  ),
                ),
            ],
          ),
        ),
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

extension OwnerNavIndex on OwnerNavItem {
  int get index => switch (this) {
        OwnerNavItem.dashboard => 0,
        OwnerNavItem.myProject => 1,
        OwnerNavItem.reports => 2,
        OwnerNavItem.profile => 3,
      };
}
