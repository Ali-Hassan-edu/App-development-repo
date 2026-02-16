import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/services/notification_service.dart';
import './providers.dart';
import '../../core/services/email_service.dart';

class TaskOperationsNotifier extends StateNotifier<bool> {
  final Ref _ref;

  TaskOperationsNotifier(this._ref) : super(false);

  Future<void> updateTaskStatusWithNotification(
    String taskId,
    String newStatus,
    TaskEntity task,
  ) async {
    state = true;
    try {
      await _ref
          .read(taskRepositoryProvider)
          .updateTaskStatus(taskId, newStatus);

      // Send notification when task is completed
      if (newStatus == 'Completed') {
        try {
          // Get all admins to notify
          final users = await _ref.read(userRepositoryProvider).getAllUsers();
          final admins = users
              .where((user) => user.role == UserRole.admin)
              .toList();

          // Send email notification to all admins
          for (final admin in admins) {
            await _ref
                .read(emailServiceProvider)
                .sendTaskCompletedNotification(
                  adminEmail: admin.email,
                  adminName: admin.name ?? 'Admin',
                  taskTitle: task.title,
                  userName: task.assignedToName ?? 'User',
                );
          }

          // Send in-app notification to all admins
          final notificationServiceNotifier = _ref.read(
            notificationServiceProvider.notifier,
          );

          for (final admin in admins) {
            final notification = NotificationModel(
              id: const Uuid().v4(),
              title: 'Task Completed',
              message:
                  'Task "${task.title}" has been completed by ${task.assignedToName ?? 'User'}',
              timestamp: DateTime.now(),
              type: NotificationType.taskCompleted,
              userId: admin.id,
            );

            notificationServiceNotifier.addNotification(notification);
          }

          print(
            'DEBUG: Task completion notifications sent to ${admins.length} admins',
          );
        } catch (e) {
          print('Error sending completion notifications: $e');
          // Don't fail the status update if notifications fail
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      state = false;
    }
  }
}

final taskOperationsNotifierProvider =
    StateNotifierProvider<TaskOperationsNotifier, bool>((ref) {
      return TaskOperationsNotifier(ref);
    });
