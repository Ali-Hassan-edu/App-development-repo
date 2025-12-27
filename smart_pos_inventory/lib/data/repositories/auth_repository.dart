import 'package:firebase_auth/firebase_auth.dart';
import '../remote/auth_remote.dart';

class AuthRepository {
  final AuthRemote remote;
  AuthRepository(this.remote);

  Stream<User?> authStateChanges() => remote.authStateChanges();
  User? get currentUser => remote.currentUser;

  Future<UserCredential> signUpWithEmail(String email, String password, String shopName) {
    return remote.signUpWithEmail(email: email, password: password, shopName: shopName);
  }

  Future<UserCredential> loginWithEmail(String email, String password) {
    return remote.loginWithEmail(email: email, password: password);
  }

  Future<UserCredential> loginWithGoogle() => remote.signInWithGoogle();

  Future<void> resetPassword(String email) => remote.sendPasswordResetEmail(email);

  Future<void> startPhone(String phone, void Function(String) onCodeSent) {
    return remote.startPhoneVerification(phoneNumber: phone, onCodeSent: onCodeSent);
  }

  Future<UserCredential> verifyOtp(String verificationId, String smsCode) {
    return remote.verifyOtp(verificationId: verificationId, smsCode: smsCode);
  }

  Future<void> updateShopName(String shopName) => remote.updateShopName(shopName);

  Future<void> logout() => remote.logout();
}
