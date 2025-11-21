import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

typedef NotificationTapCallback = void Function(NotificationResponse);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ===== ANDROID NOTIFICATION CHANNELS =====
  
  /// High priority channel for task reminders
  static const AndroidNotificationChannel _taskReminderChannel =
      AndroidNotificationChannel(
    'task_mania_reminders',
    'Task Mania Reminders',
    description: 'Important reminders for your scheduled tasks',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    ledColor: Color(0xFF6C63FF),
    showBadge: true,
  );

  /// Channel for task completion notifications
  static const AndroidNotificationChannel _taskCompleteChannel =
      AndroidNotificationChannel(
    'task_mania_completed',
    'Task Completed',
    description: 'Notifications when you complete tasks',
    importance: Importance.high,
    playSound: true,
    enableVibration: false,
  );

  /// Build rich notification details with task information
  AndroidNotificationDetails _buildTaskNotificationDetails({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? repeatRule,
  }) {
    // Build comprehensive notification content
    final StringBuffer bodyBuilder = StringBuffer();
    
    if (description != null && description.isNotEmpty) {
      bodyBuilder.writeln(description);
      bodyBuilder.writeln();
    }

    // Add priority indicator
    if (priority != null) {
      String priorityEmoji = '📌';
      switch (priority.toLowerCase()) {
        case 'high':
          priorityEmoji = '🔴';
          break;
        case 'medium':
          priorityEmoji = '🟠';
          break;
        case 'low':
          priorityEmoji = '🟢';
          break;
      }
      bodyBuilder.writeln('$priorityEmoji Priority: $priority');
    }

    // Add due date/time
    if (dueDate != null) {
      final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(dueDate);
      final formattedTime = DateFormat('h:mm a').format(dueDate);
      bodyBuilder.writeln('⏰ Due: $formattedDate at $formattedTime');
    }

    // Add repeat rule
    if (repeatRule != null && repeatRule.isNotEmpty) {
      bodyBuilder.writeln('🔄 Repeats: $repeatRule');
    }

    final bodyText = bodyBuilder.toString().trim();

    return AndroidNotificationDetails(
      _taskReminderChannel.id,
      _taskReminderChannel.name,
      channelDescription: _taskReminderChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: const Color(0xFF6C63FF),
      ledOnMs: 1000,
      ledOffMs: 500,
      showWhen: true,
      channelShowBadge: true,
      autoCancel: true,
      ongoing: false,
      styleInformation: BigTextStyleInformation(
        bodyText,
        contentTitle: title,
        summaryText: '📋 Task Mania',
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
      ),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      // Action buttons
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'mark_done',
          'Mark as Done ✓',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          'Snooze 10 min ⏰',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );
  }

  static const AndroidNotificationDetails _completedAndroidDetails =
      AndroidNotificationDetails(
    'task_mania_completed',
    'Task Completed',
    channelDescription: 'Celebration when you complete tasks',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    styleInformation: BigTextStyleInformation(
      'Great job! Keep up the momentum! 🎯',
      contentTitle: '🎉 Task Completed!',
    ),
    icon: '@mipmap/ic_launcher',
  );

  // ===== INIT =====
  Future<void> init({required NotificationTapCallback onTap}) async {
    // Timezone setup
    tz.initializeTimeZones();
    try {
      final name = tz.local.name;
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Create notification channels
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      // Create high-priority reminder channel
      await androidImpl.createNotificationChannel(_taskReminderChannel);
      // Create completion channel
      await androidImpl.createNotificationChannel(_taskCompleteChannel);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    // Android 13+ notification permission
    await requestAndroidPermissions();
  }

  // Background notification handler
  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse response) async {
    debugPrint('🔔 Background notification tapped: ${response.payload}');
    
    if (response.payload == null) return;
    
    final taskId = int.tryParse(response.payload!);
    if (taskId == null) return;
    
    // Handle notification actions in background
    if (response.actionId == 'mark_done') {
      debugPrint('✅ Mark as done action triggered in background for task $taskId');
      // Task will be marked as done when app opens
    } else if (response.actionId == 'snooze') {
      debugPrint('⏰ Snooze action triggered in background for task $taskId');
      // Snooze will be processed when app opens or via background handler
      try {
        // Reschedule for 10 minutes later
        final newTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));
        await instance._plugin.zonedSchedule(
          taskId,
          'Snoozed Task',
          '⏰ Reminder in 10 minutes - Task Mania',
          newTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_mania_reminders',
              'Task Mania Reminders',
              channelDescription: 'Important reminders for your scheduled tasks',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: taskId.toString(),
        );
        debugPrint('⏰ Task $taskId rescheduled for 10 minutes later');
      } catch (e) {
        debugPrint('❌ Error in background snooze: $e');
      }
    }
  }

  Future<void> requestAndroidPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      try {
        await androidImpl.requestExactAlarmsPermission();
        await androidImpl.requestNotificationsPermission();
      } catch (e) {
        debugPrint('requestPermissions error: $e');
      }
    }
  }

  // ===== SCHEDULE TASK REMINDER WITH FULL INFO =====
  Future<void> scheduleNotification(
    int id,
    String title,
    String? body, {
    DateTime? when,
    String? priority,
    String? repeatRule,
  }) async {
    final dueDate = when ?? DateTime.now();
    final now = DateTime.now();
    
    if (dueDate.isBefore(now)) {
      debugPrint('⚠️ Cannot schedule notification in the past: Task #$id at $dueDate');
      return;
    }

    final tzTime = tz.TZDateTime.from(dueDate, tz.local);
    debugPrint('📅 Scheduling Task Mania notification #$id for "$title" at $tzTime');

    // Build rich notification with all task details
    final notificationDetails = _buildTaskNotificationDetails(
      title: title,
      description: body,
      priority: priority,
      dueDate: dueDate,
      repeatRule: repeatRule,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        '📋 Task Mania Reminder',
        tzTime,
        NotificationDetails(android: notificationDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: id.toString(),
      );
      debugPrint('✅ Task Mania notification #$id scheduled successfully');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification #$id: $e');
      rethrow;
    }
  }

  // ===== SNOOZE NOTIFICATION =====
  Future<void> snoozeNotification(
    int id,
    String title,
    String? body, {
    String? priority,
    String? repeatRule,
  }) async {
    final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
    final tzTime = tz.TZDateTime.from(snoozeTime, tz.local);
    
    debugPrint('⏰ Snoozing Task #$id for 10 minutes to $tzTime');

    final notificationDetails = _buildTaskNotificationDetails(
      title: title,
      description: body,
      priority: priority,
      dueDate: snoozeTime,
      repeatRule: repeatRule,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        '⏰ Snoozed - Task Mania',
        tzTime,
        NotificationDetails(android: notificationDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: id.toString(),
      );
      debugPrint('✅ Task #$id snoozed successfully');
    } catch (e) {
      debugPrint('❌ Failed to snooze notification #$id: $e');
    }
  }

  // ===== TASK COMPLETED POPUP =====
  Future<void> showTaskCompleted(int id, String title) async {
    try {
      await _plugin.show(
        900000 + id,
        'Task completed',
        '"$title" marked as done 🎉',
        const NotificationDetails(android: _completedAndroidDetails),
        payload: id.toString(),
      );
    } catch (e) {
      debugPrint('showTaskCompleted error: $e');
    }
  }

  // ===== CANCELS =====
  Future<void> cancelNotification(int id) => _plugin.cancel(id);

  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  // ===== DAILY REPEAT =====
  Future<void> scheduleDaily({
    required int id,
    required String title,
    String? body,
    required TimeOfDay time,
    String? priority,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    final notificationDetails = _buildTaskNotificationDetails(
      title: title,
      description: body,
      priority: priority,
      dueDate: next,
      repeatRule: 'Daily',
    );

    try {
      await _plugin.zonedSchedule(
        id,
        '📋 Task Mania Reminder',
        title,
        next,
        NotificationDetails(android: notificationDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: id.toString(),
      );
      debugPrint('✅ Daily Task Mania reminder scheduled for $title');
    } catch (e) {
      debugPrint('❌ scheduleDaily error: $e');
    }
  }

  // ===== WEEKLY REPEAT =====
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    String? body,
    required int weekday, // 1 = Monday ... 7 = Sunday
    required TimeOfDay time,
    String? priority,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    int today = now.weekday;
    int deltaDays = (weekday - today) % 7;
    if (deltaDays < 0) deltaDays += 7;

    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(Duration(days: deltaDays));

    if (next.isBefore(now)) next = next.add(const Duration(days: 7));

    final weekdayName = DateFormat('EEEE').format(next);
    final notificationDetails = _buildTaskNotificationDetails(
      title: title,
      description: body,
      priority: priority,
      dueDate: next,
      repeatRule: 'Every $weekdayName',
    );

    try {
      await _plugin.zonedSchedule(
        id,
        '📋 Task Mania Reminder',
        title,
        next,
        NotificationDetails(android: notificationDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: id.toString(),
      );
      debugPrint('✅ Weekly Task Mania reminder scheduled for $title');
    } catch (e) {
      debugPrint('❌ scheduleWeekly error: $e');
    }
  }
}
