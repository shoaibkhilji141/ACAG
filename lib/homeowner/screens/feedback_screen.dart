import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/owner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  String? _selectedCategory;
  final _commentController = TextEditingController();
  bool _saving = false;
  String? _projectId;
  int _unread = 0;

  static const _categories = [
    'Engineer',
    'Quality',
    'Timeline',
    'Materials',
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_badge);
    _badge();
    _loadProject();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_badge);
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _badge() async {
    final n = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = n);
  }

  Future<void> _loadProject() async {
    final project = await ProjectService.primaryOwnerProject();
    if (mounted) setState(() => _projectId = project?.id);
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }
    if (_projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No project linked to submit feedback for.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await OwnerService.submitFeedback(
        projectCodeOrId: _projectId!,
        rating: _rating,
        category: _selectedCategory,
        comments: _commentController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you! Your feedback has been submitted.'),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {
        _rating = 0;
        _selectedCategory = null;
        _commentController.clear();
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Feedback',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your experience?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us improve the ACAG housing program.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Rating'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _rating = i),
                    iconSize: 40,
                    icon: Icon(
                      i <= _rating ? Icons.star : Icons.star_border,
                      color: i <= _rating
                          ? AppColors.warning
                          : AppColors.outlineVariant,
                    ),
                  ),
              ],
            ),
            if (_rating > 0)
              Center(
                child: Text(
                  _ratingLabel(_rating),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Category'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in _categories)
                  FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: _selectedCategory == category
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: _selectedCategory == category
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Comments'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share details about your experience...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _saving ? 'Submitting…' : 'Submit Feedback',
              icon: Icons.send_outlined,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    return switch (rating) {
      1 => 'Poor',
      2 => 'Fair',
      3 => 'Good',
      4 => 'Very Good',
      5 => 'Excellent',
      _ => '',
    };
  }
}
