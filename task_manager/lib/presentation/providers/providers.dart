import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../core/services/email_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../core/services/sync_service.dart';

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  ),
);

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final storageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(storageProvider),
    ref.watch(googleSignInProvider),
    ref.watch(supabaseProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(supabaseProvider));
});

final mainScreenIndexProvider = StateProvider<int>((ref) => 0);
final shouldShowAddUserDialogProvider = StateProvider<bool>((ref) => false);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.watch(supabaseProvider),
    ref.watch(syncServiceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(supabaseProvider));
});

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

final notificationServiceProvider =
    StateNotifierProvider<NotificationServiceNotifier, List<NotificationModel>>(
  (ref) => NotificationServiceNotifier(),
);
final notificationRepositoryProvider =
    Provider<NotificationRepositoryImpl>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(supabaseProvider),
    ref.watch(syncServiceProvider),
  );
});
final userNotificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});