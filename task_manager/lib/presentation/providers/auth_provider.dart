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
      final user = await _ref
          .read(authRepositoryProvider)
          .login(email, password);
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'User not found in database',
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
      state = state.copyWith(user: user, isLoading: false);
      if (user != null) {
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .createUserWithoutSession(name, email, password, role);
      // Don't update the state or save session here - this is for admin creating users
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
        await _sessionService.saveSession(
          userRole: user.role == UserRole.admin ? 'admin' : 'user',
          email: user.email,
          userId: user.id,
          name: user.name,
        );
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
      // Try to initialize Google Sign-In first
      try {
        await _ref.read(googleSignInProvider).signInSilently();
      } catch (e) {
        // Ignore Google Sign-In errors for now
        print('Google Sign-In initialization failed: $e');
      }

      // First check local session
      final session = await _sessionService.getSession();
      if (session != null) {
        // Create user entity from session data
        final user = UserEntity(
          id: session['userId'] as String,
          name: session['name'] as String,
          email: session['email'] as String,
          role: session['userRole'] == 'admin' ? UserRole.admin : UserRole.user,
        );
        state = state.copyWith(user: user, isLoading: false);
        return;
      }

      // If no local session, try Supabase
      final user = await _ref.read(authRepositoryProvider).autoLogin();
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
      // Success - password reset email sent
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    await _sessionService.clearSession();
    state = AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
