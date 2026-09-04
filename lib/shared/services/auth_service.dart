import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/image_base64.dart';
import 'notification_service.dart';

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

    invalidateProfileCache();

    final profile = await client
        .from('profiles')
        .select(
          'role, full_name, phone, cnic, email, location_text, city, is_active, profile_image_base64, profile_image_url',
        )
        .eq('id', userId)
        .maybeSingle();

    if (profile == null) {
      await client.auth.signOut();
      throw Exception('Profile not found for this account.');
    }

    _profileCache = Map<String, dynamic>.from(profile);
    _profileCacheAt = DateTime.now();

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
    invalidateProfileCache();
    NotificationService.stopPolling();
    NotificationService.invalidateCache();
    await client.auth.signOut();
  }

  static Map<String, dynamic>? _profileCache;
  static DateTime? _profileCacheAt;
  static const _profileTtl = Duration(minutes: 5);

  static void invalidateProfileCache() {
    _profileCache = null;
    _profileCacheAt = null;
  }

  static Map<String, dynamic>? get cachedProfile => _profileCache;

  static Future<Map<String, dynamic>?> currentProfile({
    bool forceRefresh = false,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final fresh = _profileCacheAt != null &&
        DateTime.now().difference(_profileCacheAt!) < _profileTtl;
    if (!forceRefresh && _profileCache != null && fresh) {
      return _profileCache;
    }

    final row =
        await client.from('profiles').select().eq('id', userId).maybeSingle();
    if (row != null) {
      _profileCache = Map<String, dynamic>.from(row);
      _profileCacheAt = DateTime.now();
    }
    return _profileCache;
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

    invalidateProfileCache();
    return base64;
  }

  static Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String locationText,
    String? cnic,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Please login again to update your profile.');
    }

    final payload = <String, dynamic>{
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'location_text': locationText.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (cnic != null) {
      payload['cnic'] = cnic.trim();
    }

    final updated = await client
        .from('profiles')
        .update(payload)
        .eq('id', userId)
        .select('id');

    if ((updated as List).isEmpty) {
      throw Exception('Could not update profile.');
    }
    invalidateProfileCache();
  }
}
