import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'app_text_field.dart';
import 'primary_button.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet to edit name, phone, location, and optional CNIC.
Future<bool?> showEditProfileSheet(
  BuildContext context, {
  required String name,
  required String phone,
  required String location,
  String? cnic,
  bool showCnic = false,
}) {
  final nameController = TextEditingController(text: name);
  final phoneController = TextEditingController(text: phone);
  final locationController = TextEditingController(text: location);
  final cnicController = TextEditingController(text: cnic ?? '');
  final formKey = GlobalKey<FormState>();
  var saving = false;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

          return Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      'Edit Profile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showCnic
                          ? 'Update your name, CNIC, contact, and address.'
                          : 'Update your name, contact number, and location.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: nameController,
                      label: 'Full Name',
                      leadingIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    if (showCnic) ...[
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: cnicController,
                        label: 'CNIC',
                        leadingIcon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'CNIC is required'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: phoneController,
                      label: 'Contact Number',
                      leadingIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Contact number is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: locationController,
                      label: 'Address',
                      leadingIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.done,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Address is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: saving ? 'Saving…' : 'Save Changes',
                      icon: Icons.check,
                      onPressed: saving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => saving = true);
                              try {
                                await AuthService.updateProfile(
                                  fullName: nameController.text,
                                  phone: phoneController.text,
                                  locationText: locationController.text,
                                  cnic: showCnic ? cnicController.text : null,
                                );
                                if (!context.mounted) return;
                                Navigator.pop(context, true);
                              } catch (e) {
                                if (!context.mounted) return;
                                setModalState(() => saving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e
                                          .toString()
                                          .replaceFirst('Exception: ', ''),
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed:
                          saving ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
