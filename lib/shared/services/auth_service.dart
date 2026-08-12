import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/image_base64.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<UserRole> signIn({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Login failed. Please try again.');
    }

    final profile = await client
        .from('profiles')
        .select(
          'role, full_name, location_text, city, profile_image_base64, profile_image_url',
        )
        .eq('id', userId)
        .maybeSingle();

    if (profile == null) {
      await client.auth.signOut();
      throw Exception('Profile not found for this account.');
    }

    final roleStr = (profile['role'] as String?)?.toLowerCase();
    final role = switch (roleStr) {
      'engineer' => UserRole.engineer,
      'owner' => UserRole.owner,
      _ => null,
    };

    if (role == null) {
      await client.auth.signOut();
      throw Exception('Unknown account role.');
    }

    if (role != selectedRole) {
      await client.auth.signOut();
      throw Exception(
        selectedRole == UserRole.engineer
            ? 'This account is not an Engineer. Select Home Owner.'
            : 'This account is not a Home Owner. Select Engineer.',
      );
    }

    return role;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<Map<String, dynamic>?> currentProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;
    return await client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  /// Saves profile image as base64 in `profiles.profile_image_base64` (no Storage).
  static Future<String?> uploadAvatar(File file) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Please login again to update profile photo.');
    }

    final ext = file.path.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final base64 = await encodeFileToBase64(file, mime: mime);
    if (base64.length > 900000) {
      throw Exception('Photo too large. Try a smaller image.');
    }

    final updated = await client
        .from('profiles')
        .update({
          'profile_image_base64': base64,
          'profile_image_url': null,
        })
        .eq('id', userId)
        .select('id');

    if ((updated as List).isEmpty) {
      throw Exception('Could not save profile photo.');
    }

    return base64;
  }
}
