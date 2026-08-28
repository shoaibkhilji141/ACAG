import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/mock_data.dart';
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
  String? _location;
  String? _imageUrl;
  File? _localImage;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.currentProfile();
    if (!mounted) return;
    setState(() {
      _name = profile?['full_name'] as String? ?? MockData.ownerName;
      _phone = profile?['phone'] as String? ?? MockData.ownerPhone;
      _email = profile?['email'] as String? ??
          AuthService.client.auth.currentUser?.email ??
          AppConstants.ownerEmail;
      _location =
          profile?['location_text'] as String? ?? MockData.ownerLocation;
      _imageUrl = profile?['profile_image_base64'] as String? ??
          profile?['profile_image_url'] as String?;
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
      name: _name ?? MockData.ownerName,
      phone: _phone ?? MockData.ownerPhone,
      location: _location ?? MockData.ownerLocation,
    );
    if (saved == true && mounted) {
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = MockData.primaryProject;
    final displayName = _name ?? MockData.ownerName;
    final displayPhone = _phone ?? MockData.ownerPhone;
    final displayEmail = _email ?? AppConstants.ownerEmail;
    final displayLocation = _location ?? MockData.ownerLocation;
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
      ),
      body: SingleChildScrollView(
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
                                imageProviderFromBase64(_imageUrl) == null)
                            ? Text(
                                initials.isEmpty ? 'AR' : initials,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayPhone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayLocation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'House Owner',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Account'),
            ),
            const SizedBox(height: 12),
            FluentCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.primary),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                onTap: _editProfile,
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Project Details'),
            ),
            const SizedBox(height: 12),
            FluentCard(
              child: Column(
                children: [
                  _ProfileField(
                    icon: Icons.tag_outlined,
                    label: 'Project ID',
                    value: project.id,
                  ),
                  const Divider(height: 24),
                  _ProfileField(
                    icon: Icons.home_work_outlined,
                    label: 'House',
                    value: project.title,
                  ),
                  const Divider(height: 24),
                  _ProfileField(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: '${project.address}, ${project.city}',
                  ),
                  const Divider(height: 24),
                  _ProfileField(
                    icon: Icons.engineering_outlined,
                    label: 'Assigned Engineer',
                    value: 'Engr. ${project.engineerName}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: SectionHeader(title: 'Contact'),
            ),
            const SizedBox(height: 12),
            FluentCard(
              child: Column(
                children: [
                  _ProfileField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: displayEmail,
                  ),
                  const Divider(height: 24),
                  _ProfileField(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: displayPhone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
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
