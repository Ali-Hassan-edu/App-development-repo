import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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

  static const String _projectRef = 'xzbljwikiygxxozijqfy';
  static const String _anonKey =
      'sb_publishable_u5r9zigh79peRXHp0Wuoig_E2WTotB0';

  AuthRepositoryImpl(this._storage, this._googleSignIn, this._supabase);

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _storage.write(key: 'admin_password', value: password);
        await _storage.write(key: 'admin_email', value: email);
        return await _getUserFromSupabase(response.user!.id);
      }
    } catch (e) {
      debugPrint('Supabase login failed: $e');
    }

    try {
      return await _localAuthService.authenticateUser(email, password);
    } catch (e) {
      debugPrint('Local auth failed: $e');
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
          'created_by_admin_id': role == UserRole.admin ? userEntity.id : null,
        });

        if (role == UserRole.admin) {
          await _storage.write(key: 'admin_email', value: email);
          await _storage.write(key: 'admin_password', value: password);
        }

        await _saveSecureSession(response.session?.accessToken ?? '', role);
        return userEntity;
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already exists') ||
          msg.contains('email address is already')) {
        rethrow;
      }
      debugPrint('Supabase signup failed: $e');
    }

    try {
      return await _localAuthService.registerUser(name, email, password, role);
    } catch (e) {
      debugPrint('Local signup failed: $e');
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
    final adminId = _supabase.auth.currentUser?.id;
    if (adminId == null) {
      debugPrint('createUserWithoutSession: No admin session');
      return null;
    }

    try {
      final existing = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        debugPrint('createUserWithoutSession: $email already exists');
        return null;
      }
    } catch (e) {
      debugPrint('Pre-check error (continuing): $e');
    }

    try {
      final token = _supabase.auth.currentSession?.accessToken ?? _anonKey;

      final res = await http.post(
        Uri.parse('https://$_projectRef.supabase.co/functions/v1/create-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role == UserRole.admin ? 'admin' : 'user',
          'admin_id': adminId,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newUserId = data['id'] as String;
        debugPrint('✅ User created via Edge Function: $newUserId');
        return UserEntity(
          id: newUserId,
          name: name,
          email: email,
          role: role,
        );
      }

      debugPrint('Edge Function error [${res.statusCode}]: ${res.body}');
    } catch (e) {
      debugPrint('Edge Function call failed: $e');
    }

    debugPrint('createUserWithoutSession: using local fallback');

    try {
      return await _localAuthService.registerUser(name, email, password, role);
    } catch (e) {
      debugPrint('Local fallback error: $e');
    }

    return null;
  }

  @override
  Future<UserEntity?> signInWithGoogle({UserRole? role}) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google Sign-In was cancelled';

      final googleAuth = await googleUser.authentication;
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
            'created_by_admin_id': userEntity.id,
          });
        }

        await _saveSecureSession(
          response.session?.accessToken ?? '',
          userEntity.role,
        );

        return userEntity;
      }
    } catch (e) {
      debugPrint('Google sign in failed: $e');
      rethrow;
    }

    return null;
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut error: $e');
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google signOut error: $e');
    }

    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userRoleKey);
    await _storage.delete(key: 'admin_password');
    await _storage.delete(key: 'admin_email');
    await _localAuthService.clearCurrentUser();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.hassan.pro.task.manager://reset-password',
    );
  }

  @override
  Future<UserEntity?> autoLogin() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        return await _getUserFromSupabase(session.user.id);
      }
    } catch (e) {
      debugPrint('Supabase auto-login failed: $e');
    }

    try {
      return await _localAuthService.getCurrentUser();
    } catch (e) {
      debugPrint('Local auto-login failed: $e');
    }

    return null;
  }

  Future<UserEntity?> _getUserFromSupabase(String uid) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', uid).maybeSingle();

      if (response != null) {
        return UserEntity(
          id: response['id'],
          name: response['name'],
          email: response['email'],
          role: response['role'] == 'admin' ? UserRole.admin : UserRole.user,
        );
      }
    } catch (e) {
      debugPrint('Error getting user from Supabase: $e');
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
