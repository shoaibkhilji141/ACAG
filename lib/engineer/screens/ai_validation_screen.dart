import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/utils/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_theme.dart';
import 'project_details_screen.dart';

class AiValidationScreen extends StatefulWidget {
  const AiValidationScreen({super.key});

  @override
  State<AiValidationScreen> createState() => _AiValidationScreenState();
}

class _AiValidationScreenState extends State<AiValidationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _analysisComplete = false;
  int _visibleChecks = 0;

  static const _score = 87;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward().then((_) {
        if (mounted) setState(() => _analysisComplete = true);
        _revealChecks();
      });
  }

  Future<void> _revealChecks() async {
    for (var i = 0; i < MockData.aiChecks.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _visibleChecks = i + 1);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _generateReport() {
    final project = projectFromRoute(context);
    Navigator.of(context).pushNamed(
      AppRoutes.engineerReport,
      arguments: project,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = projectFromRoute(context);
    final checks = MockData.aiChecks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Validation'),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            FluentCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _analysisComplete ? 1 : _progressController.value,
                              strokeWidth: 8,
                              backgroundColor:
                                  AppColors.outlineVariant.withValues(alpha: 0.3),
                              color: AppColors.primaryContainer,
                            ),
                            if (_analysisComplete)
                              Text(
                                '$_score%',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              )
                            else
                              Text(
                                '${(_progressController.value * 100).round()}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _analysisComplete ? 1 : 0.5,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _analysisComplete
                          ? 'Analysis Complete'
                          : 'Analyzing site photos...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_analysisComplete) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pass with Warning',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.tertiaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Validation Checklist',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FluentCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < checks.length; i++)
                    AnimatedOpacity(
                      opacity: i < _visibleChecks ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: _CheckItem(
                        title: checks[i].$1,
                        passed: checks[i].$2,
                        detail: checks[i].$3,
                        showDivider: i < checks.length - 1,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Generate Report',
              icon: Icons.description_outlined,
              enabled: _analysisComplete && _visibleChecks >= checks.length,
              onPressed: _generateReport,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.title,
    required this.passed,
    required this.detail,
    required this.showDivider,
  });

  final String title;
  final bool passed;
  final String detail;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = passed ? AppColors.success : AppColors.warning;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.warning_amber_rounded,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 50,
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
