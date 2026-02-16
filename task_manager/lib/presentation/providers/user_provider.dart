import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';

final usersStreamProvider = StreamProvider<List<UserEntity>>((ref) {
  return ref.watch(userRepositoryProvider).watchAllUsers();
});

// Add a provider for all users (non-streaming)
final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getAllUsers();
});

// Add a user state notifier for user operations
class UserState {
  final bool isLoading;
  final String? error;

  UserState({this.isLoading = false, this.error});

  UserState copyWith({bool? isLoading, String? error}) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref;

  UserNotifier(this._ref) : super(UserState());

  Future<void> removeUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(userRepositoryProvider).deleteUser(userId);
      // Refresh the users list after removal
      _ref.refresh(allUsersProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userStateProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});
