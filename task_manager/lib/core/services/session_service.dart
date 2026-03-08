import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _profileImageKey = 'profile_image_path';

  Future<void> saveSession({
    required String userRole,
    required String email,
    required String userId,
    required String name,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, userRole);
    await prefs.setString(_userEmailKey, email);
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    if (profileImagePath != null) {
      await prefs.setString(_profileImageKey, profileImagePath);
    }
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (!isLoggedIn) return null;
    return {
      'userRole': prefs.getString(_userRoleKey),
      'email': prefs.getString(_userEmailKey),
      'userId': prefs.getString(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'profileImagePath': prefs.getString(_profileImageKey),
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}
