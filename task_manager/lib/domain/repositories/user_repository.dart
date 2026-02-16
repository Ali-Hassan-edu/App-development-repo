import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Stream<List<UserEntity>> watchAllUsers();
  Future<void> createUser(UserEntity user, String password);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<void> removeDuplicateAdmins();
}
