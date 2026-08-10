import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/constants/stitch_screens.dart';
import '../../shared/utils/project_route.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/stitch/stitch_flow_scaffold.dart';
import '../../theme/app_theme.dart';

class ProjectHandoverScreen extends StatefulWidget {
  const ProjectHandoverScreen({super.key});

  @override
  State<ProjectHandoverScreen> createState() => _ProjectHandoverScreenState();
}

class _ProjectHandoverScreenState extends State<ProjectHandoverScreen> {
  bool _snagListCleared = true;
  bool _utilitiesConnected = true;
  bool _maintenanceGuide = false;
  int _satisfactionScore = 4;

  @override
  Widget build(BuildContext context) {
    final screen = stitchScreens[12];
    final theme = Theme.of(context);
    final project = projectFromRoute(context);

    return StitchFlowScaffold(
      screen: screen,
      moduleDescription:
          'Final handover checklist, satisfaction rating, and certificate issuance.',
      showStepIndicator: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Handover',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review completion status before issuing official documents.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FluentCard(
            padding: const EdgeInsets.all(0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: AppColors.onPrimaryContainer,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completion Certificate Preview',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Project ID: ${project.id}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Post-Construction Checklist',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _HandoverToggle(
            label: 'Snag list cleared',
            subtitle: 'All defects resolved and signed off',
            value: _snagListCleared,
            onChanged: (v) => setState(() => _snagListCleared = v),
          ),
          _HandoverToggle(
            label: 'Utilities connected',
            subtitle: 'Electricity, gas & water supply active',
            value: _utilitiesConnected,
            onChanged: (v) => setState(() => _utilitiesConnected = v),
          ),
          _HandoverToggle(
            label: 'Maintenance guide provided',
            subtitle: 'Owner handbook and warranty docs delivered',
            value: _maintenanceGuide,
            onChanged: (v) => setState(() => _maintenanceGuide = v),
          ),
          const SizedBox(height: 20),
          Text(
            'Owner Satisfaction',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          FluentCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _satisfactionScore;
                return IconButton(
                  onPressed: () => setState(() => _satisfactionScore = i + 1),
                  icon: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: filled ? AppColors.warning : AppColors.outline,
                    size: 32,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'HSE Compliance',
            icon: Icons.health_and_safety_outlined,
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.stitchHseCompliance,
                arguments: project,
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Completion Certificate',
            icon: Icons.verified_outlined,
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.stitchCompletionCertificate,
                arguments: project,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HandoverToggle extends StatelessWidget {
  const _HandoverToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FluentCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.onPrimary,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
