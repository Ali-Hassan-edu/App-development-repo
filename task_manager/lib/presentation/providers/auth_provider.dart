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
      final user = await _ref.read(authRepositoryProvider).login(email, password);
      if (user != null) {
        // Save session for persistent login
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid credentials. Please try again.',
        );
      }
    } catch (e) {
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
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Signup failed');
      }
    } catch (e) {
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
      final user = await _ref
          .read(authRepositoryProvider)
          .createUserWithoutSession(name, email, password, role);
      return user;
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
      // First check saved session (SharedPreferences) - this is the primary source
      final session = await _sessionService.getSession();
      if (session != null) {
        final user = UserEntity(
          id: session['userId'] as String,
          name: session['name'] as String,
          email: session['email'] as String,
          role: session['userRole'] == 'admin' ? UserRole.admin : UserRole.user,
        );
        state = state.copyWith(user: user, isLoading: false);
        return;
      }

      // Fall back to Supabase/local auth check
      final user = await _ref.read(authRepositoryProvider).autoLogin();
      if (user != null) {
        // Save session for next time
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );
      }
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
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

  Future<void> logout() async {
    try {
      await _ref.read(authRepositoryProvider).logout();
    } catch (e) {
      print('Logout error: $e');
    }
    // Always clear session on logout
    await _sessionService.clearSession();
    state = AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
