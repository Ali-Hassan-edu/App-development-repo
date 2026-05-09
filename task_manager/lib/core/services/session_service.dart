import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _profileImageKey = 'profile_image_path';
  static const String _sessionTimestampKey = 'session_timestamp';
  static const String _sessionExpiryKey = 'session_expiry_minutes';

  // Session expiry in minutes (24 hours)
  static const int _defaultSessionExpiryMinutes = 1440;

  /// Keys that must survive a logout (never cleared by clearSession).
  static const _preservedKeys = {'first_launch', 'first_app_launch'};

  Future<void> saveSession({
    required String userRole,
    required String email,
    required String userId,
    required String name,
    String? profileImagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      await Future.wait([
        prefs.setString(_userRoleKey, userRole),
        prefs.setString(_userEmailKey, email),
        prefs.setBool(_isLoggedInKey, true),
        prefs.setString(_userIdKey, userId),
        prefs.setString(_userNameKey, name),
        prefs.setInt(_sessionTimestampKey, now.millisecondsSinceEpoch),
        if (profileImagePath != null)
          prefs.setString(_profileImageKey, profileImagePath),
      ]);

      debugPrint('✅ Session saved successfully for user: $email');
    } catch (e) {
      debugPrint('❌ Error saving session: $e');
    }
  }

  Future<Map<String, dynamic>?> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (!isLoggedIn) {
        debugPrint('❌ Session not found - user not logged in');
        return null;
      }

      final userRole = prefs.getString(_userRoleKey);
      final email = prefs.getString(_userEmailKey);
      final userId = prefs.getString(_userIdKey);
      final name = prefs.getString(_userNameKey);

      // Avoid creating a fake/invalid in-memory user when stored session
      // is incomplete (can happen after partial writes/app interruptions).
      if (userRole == null ||
          userRole.isEmpty ||
          email == null ||
          email.isEmpty ||
          userId == null ||
          userId.isEmpty) {
        debugPrint('❌ Session invalid - required fields missing');
        return null;
      }

      final session = {
        'userRole': userRole,
        'email': email,
        'userId': userId,
        'name': name,
        'profileImagePath': prefs.getString(_profileImageKey),
      };

      debugPrint('✅ Session retrieved successfully');
      return session;
    } catch (e) {
      debugPrint('❌ Error retrieving session: $e');
      return null;
    }
  }

  /// Clears only session-related keys. Preserves `first_launch` and other
  /// app-level flags so the intro screen doesn't re-appear after logout.
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove =
          prefs.getKeys().where((k) => !_preservedKeys.contains(k)).toList();

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      debugPrint(
          '✅ Session cleared successfully. Preserved keys: $_preservedKeys');
    } catch (e) {
      debugPrint('❌ Error clearing session: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (!isLoggedIn) return false;

      return true;
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      return false;
    }
  }

  /// Refresh the session timestamp to extend its expiry
  Future<void> refreshSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_isLoggedInKey) ?? false) {
        await prefs.setInt(
            _sessionTimestampKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint('✅ Session refreshed');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing session: $e');
    }
  }
}
