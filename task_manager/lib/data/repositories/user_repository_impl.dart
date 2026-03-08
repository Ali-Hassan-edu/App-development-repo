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
      final response = await _supabase.from('users').select();
      return (response as List).map((user) => UserEntity(
        id: user['id'],
        name: user['name'],
        email: user['email'],
        role: user['role'] == 'admin' ? UserRole.admin : UserRole.user,
      )).toList();
    } catch (e) {
      print('Supabase get all users failed: $e');
      try {
        return await _localAuthService.getAllUsers();
      } catch (localError) {
        print('Local get all users failed: $localError');
        return [];
      }
    }
  }

  @override
  Stream<List<UserEntity>> watchAllUsers() {
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
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('tasks').update({'assignedToId': null}).eq('assignedToId', userId);
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      print('Supabase delete user failed: $e');
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
      print('Remove duplicate admins failed: $e');
    }
  }
}
