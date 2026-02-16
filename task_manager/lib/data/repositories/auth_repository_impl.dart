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
      // Fallback to local authentication
      try {
        return await _localAuthService.authenticateUser(email, password);
      } catch (localError) {
        print('Local auth also failed: $localError');
        rethrow;
      }
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
        await _saveSession(response.session?.accessToken ?? '', role);
        return userEntity;
      }
    } catch (e) {
      print('Supabase signup failed: $e');
      // Fallback to local registration
      try {
        final user = await _localAuthService.registerUser(
          name,
          email,
          password,
          role,
        );
        if (user != null) {
          await _localAuthService.setCurrentUser(user);
        }
        return user;
      } catch (localError) {
        print('Local signup also failed: $localError');
        rethrow;
      }
    }
    return null;
  }

  // Add a new method to create a user without setting session (for admin use)
  @override
  Future<UserEntity?> createUserWithoutSession(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      // First, create the user in Supabase Auth
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

        // Add user to our users table
        await _supabase.from('users').upsert({
          'id': userEntity.id,
          'name': userEntity.name,
          'email': userEntity.email,
          'role': role == UserRole.admin ? 'admin' : 'user',
        });

        // Don't save session here - this is for admin creating users
        return userEntity;
      }
    } catch (e) {
      print('Supabase user creation failed: $e');
      // Fallback to local registration
      try {
        return await _localAuthService.registerUser(
          name,
          email,
          password,
          role,
        );
      } catch (localError) {
        print('Local user creation also failed: $localError');
        rethrow;
      }
    }
    return null;
  }

  @override
  Future<UserEntity?> signInWithGoogle({UserRole? role}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was cancelled by user';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw 'Google Sign-In failed: No ID Token found. Please check your SHA-1 fingerprint in both Firebase and Google Cloud Console. Ensure it matches your debug keystore.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        UserEntity? userEntity = await _getUserFromSupabase(response.user!.id);
        if (userEntity == null) {
          // For Google Sign-In, always create as Admin
          userEntity = UserEntity(
            id: response.user!.id,
            name: response.user!.userMetadata?['full_name'] ?? 'New Admin',
            email: response.user!.email ?? '',
            role: UserRole.admin, // Always admin for Google Sign-In
          );
          await _supabase.from('users').upsert({
            'id': userEntity.id,
            'name': userEntity.name,
            'email': userEntity.email,
            'role': 'admin', // Always admin for Google Sign-In
          });
        }
        await _saveSession(
          response.session?.accessToken ?? '',
          userEntity.role,
        );
        return userEntity;
      }
    } catch (e) {
      if (e.toString().contains('ApiException: 10')) {
        throw 'Google Sign-In Error (10): This usually means your SHA-1 fingerprint is not registered in the Google Cloud Console or Firebase. Please ensure the SHA-1 for package "com.hassan.pro.task.manager" is added.';
      }
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
      // Continue with local cleanup anyway
    }
    await _googleSignIn.signOut();
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userRoleKey);
    await _localAuthService.clearCurrentUser();
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      print('Supabase forgot password failed: $e');
      // We can't really handle this locally, but at least log it
      rethrow;
    }
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
      // Try local auth as fallback
      try {
        return await _localAuthService.getCurrentUser();
      } catch (localError) {
        print('Local auto-login also failed: $localError');
        // Return null if both methods fail
        return null;
      }
    }
    return null;
  }

  Future<UserEntity?> _getUserFromSupabase(String uid) async {
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
    return null;
  }

  Future<void> _saveSession(String token, UserRole role) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(
      key: AppConstants.userRoleKey,
      value: role == UserRole.admin ? 'admin' : 'user',
    );
  }
}
