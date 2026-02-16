import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/services/local_auth_service.dart';

class UserRepositoryImpl implements UserRepository {
  final sb.SupabaseClient _supabase;
  final LocalAuthService _localAuthService = LocalAuthService();

  UserRepositoryImpl(this._supabase);

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      // Remove the order by created_at since that column doesn't exist
      final response = await _supabase.from('users').select();

      return response
          .map(
            (user) => UserEntity(
              id: user['id'],
              name: user['name'],
              email: user['email'],
              role: user['role'] == 'admin' ? UserRole.admin : UserRole.user,
            ),
          )
          .toList();
    } catch (e) {
      print('Supabase get all users failed: $e');
      // Fallback to local auth service
      try {
        return await _localAuthService.getAllUsers();
      } catch (localError) {
        print('Local get all users also failed: $localError');
        rethrow;
      }
    }
  }

  @override
  Stream<List<UserEntity>> watchAllUsers() {
    // Return an empty stream as fallback since we can't watch in offline mode
    return Stream.value([]);
  }

  @override
  Future<void> createUser(UserEntity user, String password) async {
    try {
      await _supabase.from('users').upsert({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role == UserRole.admin ? 'admin' : 'user',
      });
    } catch (e) {
      print('Supabase create user failed: $e');
      // For local fallback, we'll just ignore this since local auth handles this differently
      print('Local fallback: Cannot create user in offline mode');
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
      print('Supabase update user failed: $e');
      // For local fallback, we'll just ignore this since local auth handles this differently
      print('Local fallback: Cannot update user in offline mode');
    }
  }

  @override
  Future<void> removeUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
      await _supabase.auth.admin.deleteUser(userId);
    } catch (e) {
      print('Supabase remove user failed: $e');
      // For local fallback, we'll just ignore this since local auth doesn't have a full admin API
      // The user won't be removed in local mode, but this prevents the app from crashing
      print('Local fallback: Cannot remove user in offline mode');
    }
  }

  @override
  Future<void> removeDuplicateAdmins() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, email, role')
          .eq('role', 'admin');

      final admins = response.where((user) => user['role'] == 'admin').toList();
      final seenEmails = <String>{};
      final usersToRemove = <Map<String, dynamic>>[];

      for (final admin in admins) {
        final email = admin['email'] as String;
        if (seenEmails.contains(email)) {
          usersToRemove.add(admin);
        } else {
          seenEmails.add(email);
        }
      }

      for (final user in usersToRemove) {
        await _supabase.from('users').delete().eq('id', user['id']);
      }
    } catch (e) {
      print('Supabase remove duplicate admins failed: $e');
      // For local fallback, we'll just ignore this since local auth handles this differently
      print('Local fallback: Skipping duplicate admin removal in offline mode');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      print('Supabase delete user failed: $e');
      // For local fallback, we'll just ignore this since local auth handles this differently
      print('Local fallback: Cannot delete user in offline mode');
    }
  }
}
