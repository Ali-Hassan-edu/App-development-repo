import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository repo;
  AuthService(this.repo);

  Stream<User?> authStateChanges() => repo.authStateChanges();
  User? get currentUser => repo.currentUser;

  Future<UserCredential> signup(String email, String password, String shopName) {
    return repo.signUpWithEmail(email, password, shopName);
  }

  Future<UserCredential> loginWithEmail(String email, String password) {
    return repo.loginWithEmail(email, password);
  }

  Future<UserCredential> loginWithGoogle() => repo.loginWithGoogle();

  Future<void> resetPassword(String email) => repo.resetPassword(email);

  Future<void> startPhone(String phone, void Function(String) onCodeSent) {
    return repo.startPhone(phone, onCodeSent);
  }

  Future<UserCredential> verifyOtp(String verificationId, String smsCode) {
    return repo.verifyOtp(verificationId, smsCode);
  }

  Future<void> updateShopName(String name) => repo.updateShopName(name);

  Future<void> logout() => repo.logout();
}
