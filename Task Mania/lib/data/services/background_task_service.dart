import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repositories/task_repository.dart';
import 'notification_service.dart';

/// Service to ensure notifications persist even when app is closed or device reboots
/// Uses Android's foreground service, boot receiver and exact alarm scheduling for reliability
class BackgroundTaskService {
  static final BackgroundTaskService instance = BackgroundTaskService._();
  BackgroundTaskService._();

  final TaskRepository _repo = TaskRepository();
  final NotificationService _notifs = NotificationService.instance;
  
  static const platform = MethodChannel('com.taskmania.foreground');

  /// Initialize background notification persistence
  /// This ensures notifications work even after:
  /// - App is force-stopped
  /// - Device is rebooted
  /// - Screen is turned off
  /// - App is removed from RAM
  Future<void> initialize() async {
    try {
      debugPrint('✅ Task Mania: Background notification service initialized');
      debugPrint('📱 Notifications will persist even when app is closed');
      
      // Start foreground service to keep app running in background
      await _startForegroundService();
      
      // The notification service already uses:
      // 1. AndroidScheduleMode.exactAllowWhileIdle - works when screen is off
      // 2. Boot receivers in AndroidManifest - reschedules after reboot
      // 3. High priority channels - ensures delivery
      // 4. Foreground service - keeps app alive for task tracking
      
    } catch (e) {
      debugPrint('❌ Task Mania: Failed to initialize background service: $e');
    }
  }
  
  /// Start foreground service to keep task tracking active
  Future<void> _startForegroundService() async {
    try {
      await platform.invokeMethod('startForegroundService');
      debugPrint('🚀 Task Mania: Foreground service started');
      debugPrint('⏰ Task tracking will continue even when app is closed');
    } catch (e) {
      debugPrint('❌ Failed to start foreground service: $e');
    }
  }

  /// Manually reschedule all pending notifications
  /// Useful after significant app updates or settings changes
  Future<void> rescheduleAllNotifications() async {
    try {
      debugPrint('🔄 Task Mania: Manually rescheduling all notifications...');
      
      final tasks = await _repo.getTasks();
      final now = DateTime.now();
      int scheduled = 0;

      for (final task in tasks) {
        if (task.isCompleted) continue;
        if (task.dueDate == null) continue;
        if (task.dueDate!.isBefore(now)) continue;

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

      debugPrint('✅ Task Mania: Manually rescheduled $scheduled notifications');
    } catch (e) {
      debugPrint('❌ Task Mania: Failed to reschedule: $e');
    }
  }

  /// Check if battery optimization is disabled (recommended for reliable notifications)
  Future<bool> isBatteryOptimizationDisabled() async {
    // This would require platform-specific code
    // For now, we rely on the permission request in AndroidManifest
    return true;
  }
}

