import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widgets/acag_app_bar.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/edit_profile_sheet.dart';
import '../../theme/app_theme.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _picker = ImagePicker();
  String? _name;
  String? _phone;
  String? _email;
  String? _cnic;
  String? _location;
  String? _imageUrl;
  bool? _isActive;
  ProjectModel? _project;
  File? _localImage;
  bool _uploading = false;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.version.addListener(_loadBadge);
    final cached = AuthService.cachedProfile;
    if (cached != null) _applyProfile(cached);
    _load();
    _loadBadge();
  }

  @override
  void dispose() {
    NotificationService.version.removeListener(_loadBadge);
    super.dispose();
  }

  Future<void> _loadBadge() async {
    final count = await NotificationService.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  void _applyProfile(Map<String, dynamic> profile) {
    _name = profile['full_name'] as String?;
    _phone = profile['phone'] as String?;
    _email = profile['email'] as String? ??
        AuthService.client.auth.currentUser?.email;
    _cnic = profile['cnic'] as String?;
    _location = profile['location_text'] as String?;
    _isActive = profile['is_active'] as bool? ?? true;
    _imageUrl = profile['profile_image_base64'] as String? ??
        profile['profile_image_url'] as String?;
  }

  Future<void> _load() async {
    final profile = await AuthService.currentProfile();
    final project = await ProjectService.primaryOwnerProject();
    if (!mounted) return;
    setState(() {
      if (profile != null) _applyProfile(profile);
      _project = project;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 70,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _localImage = file;
      _uploading = true;
    });

    try {
      final saved = await AuthService.uploadAvatar(file);
      if (!mounted) return;
      setState(() {
        _imageUrl = saved ?? _imageUrl;
        _localImage = null;
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _editProfile() async {
    final saved = await showEditProfileSheet(
      context,
      name: _name ?? '',
      phone: _phone ?? '',
      location: _location ?? '',
      cnic: _cnic,
      showCnic: true,
    );
    if (saved == true && mounted) {
      await AuthService.currentProfile(forceRefresh: true);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  void _logout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _name ?? 'Home Owner';
    final displayPhone = _phone ?? '—';
    final displayEmail = _email ?? AppConstants.ownerEmail;
    final displayLocation = _location ?? '—';
    final displayCnic =
        (_cnic == null || _cnic!.trim().isEmpty) ? '—' : _cnic!;
    final statusLabel = (_isActive ?? true) ? 'Active' : 'Inactive';
    final initials = displayName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final progressPct = _project == null
        ? '0%'
        : '${(_project!.progress * 100).round()}%';

    final stats = [
      (label: 'Progress', value: progressPct),
      (label: 'Project', value: _project?.id ?? '—'),
      (label: 'Status', value: statusLabel),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AcagAppBar(
        title: 'Profile',
        showBranding: false,
        notificationCount: _unread,
        onNotificationTap: () {
          Navigator.of(context).pushNamed(AppRoutes.ownerNotifications);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FluentCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: _localImage != null
                            ? FileImage(_localImage!)
                            : imageProviderFromBase64(_imageUrl),
                        child: (_localImage == null &&
                                imageProviderFromBase64(_imageUrl) == null)
                            ? Text(
                                initials.isEmpty ? 'HO' : initials,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _uploading ? null : _pickImage,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _uploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.onPrimary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.photo_camera_outlined,
                                      size: 16,
                                      color: AppColors.onPrimary,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'House Owner',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(displayPhone, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayLocation,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FluentCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            stats[i].value,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stats[i].label,
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FluentCard(
              child: Column(
                children: [
                  _DetailRow(label: 'CNIC', value: displayCnic),
                  Divider(
                    height: 22,
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  _DetailRow(label: 'Email', value: displayEmail),
                  Divider(
                    height: 22,
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  _DetailRow(label: 'Account status', value: statusLabel),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FluentCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: _editProfile,
                  ),
                  _divider(),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.ownerNotifications);
                    },
                  ),
                  _divider(),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {},
                  ),
                  _divider(),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _divider(),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About ACAG',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 56,
        color: AppColors.outlineVariant.withValues(alpha: 0.35),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
      onTap: onTap,
    );
  }
}
