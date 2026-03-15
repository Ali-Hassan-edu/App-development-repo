import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';

final usersStreamProvider = StreamProvider<List<UserEntity>>((ref) {
  return ref.watch(userRepositoryProvider).watchAllUsers();
});

/// Fetches all users for the current admin.
/// Uses the session-cache fallback in UserRepositoryImpl so it works
/// even immediately after createUserWithoutSession restores the admin session.
final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  return await ref.read(userRepositoryProvider).getAllUsers();
});

class UserState {
  final bool isLoading;
  final String? error;

  UserState({this.isLoading = false, this.error});

  UserState copyWith({bool? isLoading, String? error}) {
    return UserState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref;

  UserNotifier(this._ref) : super(UserState());

  Future<void> removeUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(userRepositoryProvider).deleteUser(userId);
      _ref.invalidate(allUsersProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userStateProvider =
    StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});
