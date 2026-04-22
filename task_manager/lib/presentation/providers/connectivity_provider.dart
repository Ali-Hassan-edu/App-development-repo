import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  // Emit initial state (assume online)
  yield true;

  // Then listen to connectivity changes
  await for (final result in Connectivity().onConnectivityChanged) {
    final isOnline = result.any((r) => r != ConnectivityResult.none);
    debugPrint(isOnline ? '🌐 Online' : '📴 Offline');
    yield isOnline;
  }
});

/// Provides a simple boolean for easy checking of connectivity status
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (isOnline) => isOnline,
    loading: () => true, // Assume online while checking
    error: (_, __) => true, // Assume online on error
  );
});

/// Notifier for manual connectivity state (useful for testing or override)
class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final isOnline = result.any((r) => r != ConnectivityResult.none);
      state = isOnline;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      state = true; // Default to online
    }
  }

  void setOnline(bool isOnline) {
    state = isOnline;
  }
}

final connectivityStateProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});
