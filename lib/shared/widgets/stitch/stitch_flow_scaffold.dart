import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../constants/stitch_screens.dart';
import '../../utils/project_route.dart';
import '../../widgets/primary_button.dart';

class StitchFlowScaffold extends StatelessWidget {
  const StitchFlowScaffold({
    super.key,
    required this.screen,
    required this.body,
    this.bottomLabel,
    this.onBottomPressed,
    this.showStepIndicator = true,
    this.showModuleIntro = true,
    this.moduleDescription,
  });

  final StitchScreenDef screen;
  final Widget body;
  final String? bottomLabel;
  final VoidCallback? onBottomPressed;
  final bool showStepIndicator;
  final bool showModuleIntro;
  final String? moduleDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          screen.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showStepIndicator && screen.totalStepsInModule > 1)
                    _StepIndicator(
                      current: screen.stepInModule,
                      total: screen.totalStepsInModule,
                    ),
                  if (showModuleIntro) ...[
                    const SizedBox(height: 12),
                    _ModuleIntroCard(
                      moduleNumber: screen.moduleNumber,
                      moduleTitle: screen.moduleTitle,
                      description: moduleDescription ??
                          'Project ${project.id} — ${project.title}',
                    ),
                  ],
                  const SizedBox(height: 16),
                  body,
                ],
              ),
            ),
          ),
          if (bottomLabel != null && onBottomPressed != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: PrimaryButton(
                label: bottomLabel!,
                icon: Icons.arrow_forward,
                onPressed: onBottomPressed,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1)
            Expanded(
              child: Container(
                height: 2,
                color: i <= current
                    ? AppColors.primary
                    : AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: i <= current ? AppColors.primary : AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$i',
              style: TextStyle(
                color: i <= current ? AppColors.onPrimary : AppColors.outline,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModuleIntroCard extends StatelessWidget {
  const _ModuleIntroCard({
    required this.moduleNumber,
    required this.moduleTitle,
    required this.description,
  });

  final String moduleNumber;
  final String moduleTitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MODULE $moduleNumber',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            moduleTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

void navigateStitchNext(BuildContext context, StitchScreenDef screen) {
  final project = projectFromRoute(context);
  final next = screen.nextRoute;
  if (next == null) {
    Navigator.of(context).pop();
    return;
  }
  Navigator.of(context).pushReplacementNamed(next, arguments: project);
}
