import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/push_notification_service.dart';
import './providers.dart';

class TaskOperationsNotifier extends StateNotifier<bool> {
  final Ref _ref;
  TaskOperationsNotifier(this._ref) : super(false);

  /// Called when a user marks a task as Started or Completed.
  /// On completion:
  ///   1. Updates task status in Supabase
  ///   2. Looks up the admin who created the task using task.adminId
  ///      (works even when a regular user is logged in — no admin_id filter needed)
  ///   3. Sends in-app notification + email to that admin
  Future<void> updateTaskStatusWithNotification(
    String taskId,
    String newStatus,
    TaskEntity task,
  ) async {
    state = true;
    try {
      // Step 1 — update DB
      await _ref
          .read(taskRepositoryProvider)
          .updateTaskStatus(taskId, newStatus);

      // Step 2 — notify only on completion
      if (newStatus == 'Completed') {
        final completedByName = task.assignedToName ?? 'User';

        // Use task.adminId to fetch the specific admin who owns this task.
        // This works even when the current session belongs to a regular user.
        List<UserEntity> admins = [];
        if (task.adminId != null && task.adminId!.isNotEmpty) {
          try {
            final admin = await _ref
                .read(userRepositoryProvider)
                .getAdminByTaskAdminId(task.adminId!);
            if (admin != null) admins = [admin];
          } catch (e) {
            debugPrint('Failed to fetch admin by task.adminId: $e');
          }
        }

        // Fallback: try getAllUsers if adminId wasn't available
        if (admins.isEmpty) {
          try {
            final users = await _ref.read(userRepositoryProvider).getAllUsers();
            admins = users.where((u) => u.role == UserRole.admin).toList();
          } catch (e) {
            debugPrint('Fallback admin fetch also failed: $e');
          }
        }

        for (final admin in admins) {
          // In-app notification
          await _ref.read(notificationRepositoryProvider).createNotification(
                userId: admin.id,
                title: '✅ Task Completed',
                message: '"${task.title}" completed by $completedByName',
                type: NotificationType.taskCompleted,
              );

          // Email notification — non-fatal
          try {
            await _ref.read(emailServiceProvider).sendTaskCompletedNotification(
                  adminEmail: admin.email,
                  adminName: admin.name,
                  taskTitle: task.title,
                  userName: completedByName,
                );
          } catch (e) {
            debugPrint('Email to admin ${admin.email} failed: $e');
          }
        }

        try {
          await PushNotificationService().showTaskCompleted(
            taskTitle: task.title,
            by: completedByName,
          );
        } catch (e) {
          debugPrint('Push notification failed: $e');
        }
      }
    } catch (e) {
      debugPrint('updateTaskStatusWithNotification error: $e');
      rethrow;
    } finally {
      state = false;
    }
  }
}

final taskOperationsNotifierProvider =
    StateNotifierProvider<TaskOperationsNotifier, bool>((ref) {
  return TaskOperationsNotifier(ref);
});
