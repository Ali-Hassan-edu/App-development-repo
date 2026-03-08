import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> signup(
    String name,
    String email,
    String password,
    UserRole role,
  );
  Future<UserEntity?> createUserWithoutSession(
    String name,
    String email,
    String password,
    UserRole role,
  );
  Future<void> forgotPassword(String email);
  Future<UserEntity?> signInWithGoogle({UserRole? role});
  Future<void> logout();
  Future<UserEntity?> autoLogin();
}
