import 'package:flutter/material.dart';

import '../constants/construction_modules.dart';
import '../utils/project_route.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class ConstructionModuleScreen extends StatelessWidget {
  const ConstructionModuleScreen({
    super.key,
    required this.module,
  });

  final ConstructionModuleInfo module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);
    final moduleScreens = screensForModule(module.number);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Module ${module.number}'),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FluentCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: module.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(module.icon, color: module.accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          module.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    module.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    project.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Module Screens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (final screen in moduleScreens) ...[
              _ScreenLinkTile(
                number: screen.number,
                title: screen.title,
                accentColor: module.accentColor,
                onTap: () => Navigator.of(context).pushNamed(
                  screen.route,
                  arguments: project,
                ),
              ),
              const SizedBox(height: 10),
            ],
            PrimaryButton(
              label: 'Start Module',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.of(context).pushNamed(
                module.firstScreenRoute,
                arguments: project,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenLinkTile extends StatelessWidget {
  const _ScreenLinkTile({
    required this.number,
    required this.title,
    required this.accentColor,
    required this.onTap,
  });

  final int number;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FluentCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: accentColor.withValues(alpha: 0.14),
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}
