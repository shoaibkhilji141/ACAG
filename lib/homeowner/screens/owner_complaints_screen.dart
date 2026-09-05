import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/owner_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_placeholder.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class OwnerComplaintsScreen extends StatefulWidget {
  const OwnerComplaintsScreen({super.key});

  @override
  State<OwnerComplaintsScreen> createState() => _OwnerComplaintsScreenState();
}

class _OwnerComplaintsScreenState extends State<OwnerComplaintsScreen> {
  List<Map<String, dynamic>> _items = const [];
  String? _projectId;
  bool _loading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_badge);
    _badge();
    _load();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_badge);
    super.dispose();
  }

  Future<void> _badge() async {
    final n = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = n);
  }

  Future<void> _load({bool force = false}) async {
    final project = await ProjectService.primaryOwnerProject();
    if (project == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _items = [];
          _projectId = null;
        });
      }
      return;
    }
    final rows = await OwnerService.listComplaints(
      project.id,
      forceRefresh: force,
    );
    if (!mounted) return;
    setState(() {
      _projectId = project.id;
      _items = rows;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    if (_projectId == null) return;
    final created = await Navigator.of(context).pushNamed(
      AppRoutes.ownerComplaintCreate,
      arguments: _projectId,
    );
    if (created == true) await _load(force: true);
  }

  Color _statusColor(String status) {
    return switch (status) {
      'resolved' => AppColors.success,
      'in_progress' => AppColors.primary,
      'under_review' => AppColors.warning,
      _ => AppColors.onSurfaceVariant,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'submitted' => 'Submitted',
      'under_review' => 'Under Review',
      'in_progress' => 'In Progress',
      'resolved' => 'Resolved',
      _ => status,
    };
  }

  void _openDetail(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final status = (item['status'] as String?) ?? 'submitted';
    final created = item['created_at'] as String?;
    final date = created == null
        ? '—'
        : DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(created).toLocal());
    final response = (item['response_text'] as String?)?.trim() ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item['category'] as String? ?? 'Complaint',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(_statusLabel(status)),
                  backgroundColor:
                      _statusColor(status).withValues(alpha: 0.12),
                  labelStyle: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                _kv('Date', date),
                _kv('Priority', (item['priority'] as String? ?? 'medium')),
                _kv(
                  'Location',
                  (item['location_text'] as String?)?.trim().isNotEmpty == true
                      ? item['location_text'] as String
                      : '—',
                ),
                _kv('Description', item['description'] as String? ?? '—'),
                _kv(
                  'Admin / engineer response',
                  response.isEmpty ? 'No response yet' : response,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            v,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Complaints',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      floatingActionButton: _projectId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openCreate,
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('New Complaint'),
            ),
      body: RefreshIndicator(
        onRefresh: () => _load(force: true),
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _items.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      EmptyPlaceholder(
                        icon: Icons.report_problem_outlined,
                        message:
                            'No complaints yet. Tap New Complaint to submit an issue.',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final status = (item['status'] as String?) ?? 'submitted';
                      final created = item['created_at'] as String?;
                      final date = created == null
                          ? '—'
                          : DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(created).toLocal());

                      return FluentCard(
                        onTap: () => _openDetail(item),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _statusColor(status)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.report_problem_outlined,
                                color: _statusColor(status),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['category'] as String? ?? 'Complaint',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'] as String? ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(status)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _statusLabel(status),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class OwnerComplaintCreateScreen extends StatefulWidget {
  const OwnerComplaintCreateScreen({super.key});

  @override
  State<OwnerComplaintCreateScreen> createState() =>
      _OwnerComplaintCreateScreenState();
}

class _OwnerComplaintCreateScreenState
    extends State<OwnerComplaintCreateScreen> {
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  String? _category;
  String _priority = 'medium';
  final List<String> _photos = [];
  bool _saving = false;

  static const _categories = [
    'Quality',
    'Delay',
    'Materials',
    'Engineer visit',
    'Safety',
    'Other',
  ];

  @override
  void dispose() {
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 75,
    );
    if (picked == null) return;
    final b64 = await encodeFileToBase64(File(picked.path));
    setState(() => _photos.add(b64));
  }

  Future<void> _submit() async {
    final projectId = ModalRoute.of(context)?.settings.arguments as String?;
    if (projectId == null) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a complaint category')),
      );
      return;
    }
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await OwnerService.submitComplaint(
        projectCodeOrId: projectId,
        category: _category!,
        description: _descController.text,
        priority: _priority,
        locationText: _locationController.text,
        photoBase64List: _photos,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted')),
      );
      Navigator.pop(context, true);
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
        title: 'New Complaint',
        showBranding: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  FilterChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (v) =>
                        setState(() => _category = v ? c : null),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Priority',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'low', label: Text('Low')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'high', label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe the issue…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Location (optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Front elevation / Kitchen',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Photos',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_photos.isNotEmpty)
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final bytes = decodeBase64Image(_photos[i]);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: bytes == null
                          ? Container(
                              width: 88,
                              color: AppColors.surfaceContainer,
                            )
                          : Image.memory(
                              bytes,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _saving ? 'Submitting…' : 'Submit Complaint',
              icon: Icons.send_outlined,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
