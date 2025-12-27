import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  AuthProvider(this._service);

  User? user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool get isLoggedIn => user != null;

  StreamSubscription<User?>? _sub;

  /// ✅ Call this once from main.dart
  void bootstrap() {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _service.authStateChanges().listen((u) {
      user = u;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String?> login(String email, String password) async {
    try {
      await _service.loginWithEmail(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signup(String email, String password, String shopName) async {
    try {
      await _service.signup(email, password, shopName);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      await _service.loginWithGoogle();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _service.resetPassword(email);
      return "Password reset email sent";
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  /// ✅ USED BY login_screen.dart
  Future<String?> startPhone(String phone, void Function(String verificationId) onCodeSent) async {
    try {
      await _service.startPhone(phone, (id) => onCodeSent(id));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  /// ✅ USED BY login_screen.dart
  Future<String?> verifyOtp(String verificationId, String smsCode) async {
    try {
      await _service.verifyOtp(verificationId, smsCode);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
