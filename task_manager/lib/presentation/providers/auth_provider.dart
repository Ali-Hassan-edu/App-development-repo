import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';
import '../../core/services/session_service.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserEntity? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final SessionService _sessionService = SessionService();

  AuthNotifier(this._ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user =
          await _ref.read(authRepositoryProvider).login(email, password);

      if (user != null) {
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );

        debugPrint('✅ Login successful: ${user.email}');
        state = state.copyWith(user: user, isLoading: false);
      } else {
        debugPrint('❌ Login failed: Invalid credentials');
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid credentials. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signup(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .signup(name, email, password, role);

      if (user != null) {
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );

        debugPrint('✅ Signup successful: ${user.email} (${user.role})');
        state = state.copyWith(user: user, isLoading: false);
      } else {
        debugPrint('❌ Signup failed');
        state = state.copyWith(isLoading: false, error: 'Signup failed');
      }
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<UserEntity?> createUserWithoutSession(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      return await _ref
          .read(authRepositoryProvider)
          .createUserWithoutSession(name, email, password, role);
    } catch (e) {
      print('Create user without session error: $e');
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _ref.read(authRepositoryProvider).signInWithGoogle();

      if (user != null) {
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );

        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> autoLogin() async {
    state = state.copyWith(isLoading: true);

    try {
      // Step 1: Try to get session from local storage (PRIORITY)
      final session = await _sessionService.getSession();

      if (session != null) {
        // Session exists and hasn't expired
        final roleStr = session['userRole']?.toString() ?? '';
        final idStr = session['userId'] as String? ?? '';
        final emailStr = session['email'] as String? ?? '';
        final nameStr = session['name'] as String? ?? '';

        // Ensure robust parsing
        final isAdmin = roleStr.contains('admin');

        final user = UserEntity(
          id: idStr.isEmpty
              ? 'user_${DateTime.now().millisecondsSinceEpoch}'
              : idStr,
          name: nameStr.isEmpty ? 'User' : nameStr,
          email: emailStr,
          role: isAdmin ? UserRole.admin : UserRole.user,
        );

        debugPrint(
            '✅ Auto-login successful with cached session: ${user.email}');
        state = state.copyWith(user: user, isLoading: false);
        return;
      }

      // Step 2: If no valid local session, try server-side auth (might require internet)
      debugPrint(
          'ℹ️ No valid local session, attempting server-side autoLogin...');
      final user = await _ref.read(authRepositoryProvider).autoLogin();

      if (user != null) {
        // Save the session for future offline use
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );

        debugPrint(
            '✅ Auto-login successful with server-side session: ${user.email}');
        state = state.copyWith(user: user, isLoading: false);
      } else {
        debugPrint('❌ Auto-login failed - no user found');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('❌ Auto-login error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _ref.read(authRepositoryProvider).forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserName(String newName) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    final updatedUser = UserEntity(
      id: currentUser.id,
      name: newName,
      email: currentUser.email,
      role: currentUser.role,
    );

    await _ref.read(userRepositoryProvider).updateUser(updatedUser);

    await _sessionService.saveSession(
      userRole: currentUser.role == UserRole.admin ? 'admin' : 'user',
      email: currentUser.email,
      userId: currentUser.id,
      name: newName,
    );

    state = state.copyWith(user: updatedUser);
  }

  Future<void> logout() async {
    try {
      debugPrint('🔓 Logging out user...');
      await _ref.read(authRepositoryProvider).logout();
    } catch (e) {
      debugPrint('⚠️ Logout error (continuing): $e');
    }

    await _sessionService.clearSession();
    state = AuthState();
    debugPrint('✅ User logged out completely');
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
