import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/services/local_auth_service.dart';

class UserRepositoryImpl implements UserRepository {
  final sb.SupabaseClient _supabase;
  final LocalAuthService _localAuthService = LocalAuthService();

  UserRepositoryImpl(this._supabase);

  /// Returns the current user's id — from Supabase session if available,
  /// otherwise falls back to the SharedPreferences session cache.
  /// This prevents "No logged-in admin found" when Supabase session is
  /// temporarily null during admin-session-restore after createUser.
  Future<String?> _getCurrentUserId() async {
    final supabaseId = _supabase.auth.currentUser?.id;
    if (supabaseId != null) return supabaseId;

    // Fallback: read from local session cache
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final currentAdminId = await _getCurrentUserId();

      if (currentAdminId == null) {
        print('getAllUsers: No session found');
        return [];
      }

      final response = await _supabase
          .from('users')
          .select()
          .or('created_by_admin_id.eq.$currentAdminId,id.eq.$currentAdminId');

      final seen = <String>{};
      final users = <UserEntity>[];
      for (final user in (response as List)) {
        final uid = user['id'] as String;
        if (seen.add(uid)) {
          users.add(UserEntity(
            id: uid,
            name: user['name'],
            email: user['email'],
            role: user['role'] == 'admin' ? UserRole.admin : UserRole.user,
          ));
        }
      }
      return users;
    } catch (e) {
      print('Supabase getAllUsers failed: $e');
      try {
        return await _localAuthService.getAllUsers();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Stream<List<UserEntity>> watchAllUsers() {
    try {
      final currentAdminId = _supabase.auth.currentUser?.id;
      if (currentAdminId == null) return Stream.value([]);

      return _supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('created_by_admin_id', currentAdminId)
          .map((snapshot) => snapshot
              .map((u) => UserEntity(
                    id: u['id'],
                    name: u['name'],
                    email: u['email'],
                    role: u['role'] == 'admin'
                        ? UserRole.admin
                        : UserRole.user,
                  ))
              .toList());
    } catch (e) {
      print('watchAllUsers failed: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<void> createUser(UserEntity user, String password) async {
    try {
      final currentAdminId = _supabase.auth.currentUser?.id;
      await _supabase.from('users').upsert({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role == UserRole.admin ? 'admin' : 'user',
        'created_by_admin_id': currentAdminId,
      });
    } catch (e) {
      print('createUser failed: $e');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _supabase
          .from('users')
          .update({
            'name': user.name,
            'email': user.email,
            'role': user.role == UserRole.admin ? 'admin' : 'user',
          })
          .eq('id', user.id);
    } catch (e) {
      print('updateUser failed: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase
          .from('tasks')
          .update({'assignedToId': null})
          .eq('assignedToId', userId);
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      print('deleteUser failed: $e');
    }
  }

  @override
  Future<void> removeDuplicateAdmins() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, email, role')
          .eq('role', 'admin');

      final admins = (response as List).cast<Map<String, dynamic>>();
      final seenEmails = <String>{};
      for (final admin in admins) {
        final email = admin['email'] as String;
        if (seenEmails.contains(email)) {
          await _supabase.from('users').delete().eq('id', admin['id']);
        } else {
          seenEmails.add(email);
        }
      }
    } catch (e) {
      print('removeDuplicateAdmins failed: $e');
    }
  }

  @override
  Future<UserEntity?> getAdminByTaskAdminId(String taskAdminId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', taskAdminId)
          .maybeSingle();
      if (response == null) return null;
      return UserEntity(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        role: response['role'] == 'admin' ? UserRole.admin : UserRole.user,
      );
    } catch (e) {
      print('getAdminByTaskAdminId failed: $e');
      return null;
    }
  }
}
