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
    int expiryMinutes = _defaultSessionExpiryMinutes,
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
        prefs.setInt(_sessionExpiryKey, expiryMinutes),
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

      // Check session expiry
      final sessionTimestamp = prefs.getInt(_sessionTimestampKey);
      final expiryMinutes =
          prefs.getInt(_sessionExpiryKey) ?? _defaultSessionExpiryMinutes;

      if (sessionTimestamp != null) {
        final sessionAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(sessionTimestamp),
        );

        if (sessionAge.inMinutes > expiryMinutes) {
          debugPrint('⏰ Session expired after ${sessionAge.inMinutes} minutes');
          await clearSession();
          return null;
        }
      }

      final session = {
        'userRole': prefs.getString(_userRoleKey),
        'email': prefs.getString(_userEmailKey),
        'userId': prefs.getString(_userIdKey),
        'name': prefs.getString(_userNameKey),
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

      // Check expiry even for this check
      final sessionTimestamp = prefs.getInt(_sessionTimestampKey);
      final expiryMinutes =
          prefs.getInt(_sessionExpiryKey) ?? _defaultSessionExpiryMinutes;

      if (sessionTimestamp != null) {
        final sessionAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(sessionTimestamp),
        );

        if (sessionAge.inMinutes > expiryMinutes) {
          await clearSession();
          return false;
        }
      }

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
