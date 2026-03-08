import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../core/utils/constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/local_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FlutterSecureStorage _storage;
  final GoogleSignIn _googleSignIn;
  final sb.SupabaseClient _supabase;
  final LocalAuthService _localAuthService = LocalAuthService();

  AuthRepositoryImpl(this._storage, this._googleSignIn, this._supabase);

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return await _getUserFromSupabase(response.user!.id);
      }
    } catch (e) {
      print('Supabase login failed: $e');
    }
    // Fallback to local
    try {
      return await _localAuthService.authenticateUser(email, password);
    } catch (e) {
      print('Local auth failed: $e');
    }
    return null;
  }

  @override
  Future<UserEntity?> signup(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user != null) {
        final userEntity = UserEntity(
          id: response.user!.id,
          name: name,
          email: email,
          role: role,
        );
        await _supabase.from('users').upsert({
          'id': userEntity.id,
          'name': userEntity.name,
          'email': userEntity.email,
          'role': role == UserRole.admin ? 'admin' : 'user',
        });
        await _saveSecureSession(response.session?.accessToken ?? '', role);
        return userEntity;
      }
    } catch (e) {
      print('Supabase signup failed: $e');
    }
    try {
      return await _localAuthService.registerUser(name, email, password, role);
    } catch (e) {
      print('Local signup failed: $e');
    }
    return null;
  }

  @override
  Future<UserEntity?> createUserWithoutSession(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user != null) {
        final userEntity = UserEntity(
          id: response.user!.id,
          name: name,
          email: email,
          role: role,
        );
        await _supabase.from('users').upsert({
          'id': userEntity.id,
          'name': userEntity.name,
          'email': userEntity.email,
          'role': role == UserRole.admin ? 'admin' : 'user',
        });
        return userEntity;
      }
    } catch (e) {
      print('Supabase user creation failed: $e');
    }
    try {
      return await _localAuthService.registerUser(name, email, password, role);
    } catch (e) {
      print('Local user creation failed: $e');
    }
    return null;
  }

  @override
  Future<UserEntity?> signInWithGoogle({UserRole? role}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google Sign-In was cancelled';
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) throw 'No ID Token found';
      final response = await _supabase.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      if (response.user != null) {
        UserEntity? userEntity = await _getUserFromSupabase(response.user!.id);
        if (userEntity == null) {
          userEntity = UserEntity(
            id: response.user!.id,
            name: response.user!.userMetadata?['full_name'] ?? 'Admin',
            email: response.user!.email ?? '',
            role: UserRole.admin,
          );
          await _supabase.from('users').upsert({
            'id': userEntity.id,
            'name': userEntity.name,
            'email': userEntity.email,
            'role': 'admin',
          });
        }
        await _saveSecureSession(response.session?.accessToken ?? '', userEntity.role);
        return userEntity;
      }
    } catch (e) {
      print('Google sign in failed: $e');
      rethrow;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Supabase logout failed: $e');
    }
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out failed: $e');
    }
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userRoleKey);
    await _localAuthService.clearCurrentUser();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<UserEntity?> autoLogin() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        return await _getUserFromSupabase(session.user.id);
      }
    } catch (e) {
      print('Supabase auto-login failed: $e');
    }
    try {
      return await _localAuthService.getCurrentUser();
    } catch (e) {
      print('Local auto-login failed: $e');
    }
    return null;
  }

  Future<UserEntity?> _getUserFromSupabase(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (response != null) {
        return UserEntity(
          id: response['id'],
          name: response['name'],
          email: response['email'],
          role: response['role'] == 'admin' ? UserRole.admin : UserRole.user,
        );
      }
    } catch (e) {
      print('Error getting user from Supabase: $e');
    }
    return null;
  }

  Future<void> _saveSecureSession(String token, UserRole role) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(
      key: AppConstants.userRoleKey,
      value: role == UserRole.admin ? 'admin' : 'user',
    );
  }
}
