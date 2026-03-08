import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/services/notification_service.dart';
import './providers.dart';

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
      await _ref.read(taskRepositoryProvider).updateTaskStatus(taskId, newStatus);

      if (newStatus == 'Completed') {
        try {
          final users = await _ref.read(userRepositoryProvider).getAllUsers();
          final admins = users.where((u) => u.role == UserRole.admin).toList();

          final notificationServiceNotifier =
              _ref.read(notificationServiceProvider.notifier);

          for (final admin in admins) {
            // Send email notification to admin
            await _ref.read(emailServiceProvider).sendTaskCompletedNotification(
              adminEmail: admin.email,
              adminName: admin.name,
              taskTitle: task.title,
              userName: task.assignedToName ?? 'User',
            );

            // Add in-app notification for admin
            notificationServiceNotifier.addNotification(
              NotificationModel(
                id: const Uuid().v4(),
                title: 'Task Completed',
                message:
                    'Task "${task.title}" has been completed by ${task.assignedToName ?? 'User'}',
                timestamp: DateTime.now(),
                type: NotificationType.taskCompleted,
                userId: admin.id,
              ),
            );
          }
        } catch (e) {
          print('Error sending completion notifications: $e');
        }
      }
    } catch (e) {
      print('Error updating task status: $e');
    } finally {
      state = false;
    }
  }
}

final taskOperationsNotifierProvider =
    StateNotifierProvider<TaskOperationsNotifier, bool>((ref) {
  return TaskOperationsNotifier(ref);
});
