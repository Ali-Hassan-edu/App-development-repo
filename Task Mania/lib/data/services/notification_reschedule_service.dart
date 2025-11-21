import 'package:flutter/foundation.dart';
import '../repositories/task_repository.dart';
import 'notification_service.dart';

/// Service to reschedule all pending notifications
/// This ensures notifications work even after device reboot or app closure
class NotificationRescheduleService {
  static final NotificationRescheduleService instance = NotificationRescheduleService._();
  NotificationRescheduleService._();

  final TaskRepository _repo = TaskRepository();
  final NotificationService _notifs = NotificationService.instance;

  /// Reschedule all active task notifications
  /// Call this on app startup and after device boot
  Future<void> rescheduleAllNotifications() async {
    try {
      debugPrint('🔄 Task Mania: Rescheduling all notifications...');
      
      final tasks = await _repo.getTasks();
      final now = DateTime.now();
      int scheduled = 0;

      for (final task in tasks) {
        // Skip completed tasks
        if (task.isCompleted) continue;
        
        // Skip tasks without due date
        if (task.dueDate == null) continue;
        
        // Skip past due dates
        if (task.dueDate!.isBefore(now)) continue;

        // Schedule notification with full task information
        await _notifs.scheduleNotification(
          task.id!,
          task.title,
          task.description,
          when: task.dueDate!,
          priority: task.priority,
          repeatRule: task.repeatRule,
        );
        scheduled++;
      }

      debugPrint('✅ Task Mania: Rescheduled $scheduled notifications successfully');
    } catch (e) {
      debugPrint('❌ Task Mania: Failed to reschedule notifications: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifs.cancelAllNotifications();
    debugPrint('🚫 Task Mania: All notifications cancelled');
  }
}
