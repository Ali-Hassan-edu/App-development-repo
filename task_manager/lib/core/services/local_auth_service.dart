import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';

class LocalAuthService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  Future<bool> initializeAdminUser() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      final defaultAdmin = {
        'id': 'local_admin_1',
        'name': 'Admin User',
        'email': 'admin@taskmanager.local',
        'role': 'admin',
        'password': 'admin123',
      };
      await prefs.setString(_usersKey, jsonEncode([defaultAdmin]));
      return true;
    }
    return false;
  }

  Future<UserEntity?> authenticateUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      await initializeAdminUser();
      return authenticateUser(email, password);
    }
    try {
      final users = (jsonDecode(usersJson) as List).cast<Map<String, dynamic>>();
      final user = users.where((u) => u['email'] == email).firstOrNull;
      if (user != null) {
        return UserEntity(
          id: user['id'] as String,
          name: user['name'] as String,
          email: user['email'] as String,
          role: user['role'] == 'admin' ? UserRole.admin : UserRole.user,
        );
      }
    } catch (e) {
      print('Error authenticating user locally: $e');
    }
    return null;
  }

  Future<UserEntity?> registerUser(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      await initializeAdminUser();
      return registerUser(name, email, password, role);
    }
    try {
      final users = (jsonDecode(usersJson) as List).cast<Map<String, dynamic>>();
      final existingUser = users.where((u) => u['email'] == email).firstOrNull;
      if (existingUser != null) return null;
      final newUser = {
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'role': role == UserRole.admin ? 'admin' : 'user',
        'password': password,
      };
      users.add(newUser);
      await prefs.setString(_usersKey, jsonEncode(users));
      return UserEntity(
        id: newUser['id'] as String,
        name: newUser['name'] as String,
        email: newUser['email'] as String,
        role: role,
      );
    } catch (e) {
      print('Error registering user locally: $e');
      return null;
    }
  }

  Future<void> setCurrentUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentUserKey,
      jsonEncode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role == UserRole.admin ? 'admin' : 'user',
      }),
    );
  }

  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString(_currentUserKey);
    if (currentUserJson == null) return null;
    try {
      final userData = jsonDecode(currentUserJson) as Map<String, dynamic>;
      return UserEntity(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        role: userData['role'] == 'admin' ? UserRole.admin : UserRole.user,
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<List<UserEntity>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      await initializeAdminUser();
      return getAllUsers();
    }
    try {
      final users = (jsonDecode(usersJson) as List).cast<Map<String, dynamic>>();
      return users.map((u) => UserEntity(
        id: u['id'] as String,
        name: u['name'] as String,
        email: u['email'] as String,
        role: u['role'] == 'admin' ? UserRole.admin : UserRole.user,
      )).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }
}
