import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/models/models.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/project_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/edit_profile_sheet.dart';
import '../../shared/widgets/section_header.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final cached = AuthService.cachedProfile;
    if (cached != null) {
      _applyProfile(cached);
      _loading = false;
    }
    _load();
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
      _loading = false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _name ?? 'Home Owner';
    final displayPhone = _phone ?? '—';
    final displayEmail = _email ?? AppConstants.ownerEmail;
    final displayLocation = _location ?? '—';
    final displayCnic = (_cnic == null || _cnic!.trim().isEmpty)
        ? '—'
        : _cnic!;
    final statusLabel = (_isActive ?? true) ? 'Active' : 'Inactive';
    final initials = displayName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.ownerNotifications);
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  FluentCard(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryContainer,
                              backgroundImage: _localImage != null
                                  ? FileImage(_localImage!)
                                  : imageProviderFromBase64(_imageUrl),
                              child: (_localImage == null &&
                                      imageProviderFromBase64(_imageUrl) ==
                                          null)
                                  ? Text(
                                      initials.isEmpty ? 'HO' : initials,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
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
                                  child: const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Icon(
                                      Icons.photo_camera_outlined,
                                      size: 14,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayPhone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (_isActive ?? true)
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Account: $statusLabel',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: (_isActive ?? true)
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SectionHeader(title: 'Personal Details'),
                  ),
                  const SizedBox(height: 12),
                  FluentCard(
                    child: Column(
                      children: [
                        _ProfileField(
                          icon: Icons.person_outline,
                          label: 'Name',
                          value: displayName,
                        ),
                        const Divider(height: 24),
                        _ProfileField(
                          icon: Icons.badge_outlined,
                          label: 'CNIC',
                          value: displayCnic,
                        ),
                        const Divider(height: 24),
                        _ProfileField(
                          icon: Icons.phone_outlined,
                          label: 'Phone number',
                          value: displayPhone,
                        ),
                        const Divider(height: 24),
                        _ProfileField(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: displayEmail,
                        ),
                        const Divider(height: 24),
                        _ProfileField(
                          icon: Icons.home_outlined,
                          label: 'Address',
                          value: displayLocation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FluentCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined,
                          color: AppColors.primary),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.outline),
                      onTap: _editProfile,
                    ),
                  ),
                  if (_project != null) ...[
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: SectionHeader(title: 'Linked Project'),
                    ),
                    const SizedBox(height: 12),
                    FluentCard(
                      child: Column(
                        children: [
                          _ProfileField(
                            icon: Icons.tag_outlined,
                            label: 'Project ID',
                            value: _project!.id,
                          ),
                          const Divider(height: 24),
                          _ProfileField(
                            icon: Icons.home_work_outlined,
                            label: 'House',
                            value: _project!.title,
                          ),
                          const Divider(height: 24),
                          _ProfileField(
                            icon: Icons.location_on_outlined,
                            label: 'Site',
                            value: _project!.locationLine,
                          ),
                          const Divider(height: 24),
                          _ProfileField(
                            icon: Icons.engineering_outlined,
                            label: 'Assigned Engineer',
                            value: _project!.engineerName,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () async {
                      NotificationService.stopPolling();
                      await AuthService.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      'Logout',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
