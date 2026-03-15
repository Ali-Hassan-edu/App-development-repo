import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Stream<List<UserEntity>> watchAllUsers();
  Future<void> createUser(UserEntity user, String password);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<void> removeDuplicateAdmins();
  /// Fetches the admin who created a task by task's admin_id field.
  /// Works even when a regular user is logged in.
  Future<UserEntity?> getAdminByTaskAdminId(String taskAdminId);
}
