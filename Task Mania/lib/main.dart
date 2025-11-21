import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/app_router.dart';
import 'data/services/notification_service.dart';
import 'data/services/notification_reschedule_service.dart';
import 'data/services/background_task_service.dart';
import 'data/services/permission_service.dart';
import 'data/repositories/task_repository.dart';
import 'features/task_management/providers/task_provider.dart';

void _onNotificationTap(NotificationResponse response) async {
  debugPrint('📱 Task Mania notification tapped: ${response.payload}');
  
  if (response.payload == null) return;
  
  final taskId = int.tryParse(response.payload!);
  if (taskId == null) return;
  
  // Handle notification actions
  if (response.actionId == 'mark_done') {
    debugPrint('✅ Mark as done action triggered for task $taskId');
    // Load task and mark as complete
    try {
      final repo = TaskRepository();
      final task = await repo.getTaskById(taskId);
      if (task != null) {
        await repo.updateTask(task.copyWith(isCompleted: true));
        await NotificationService.instance.cancelNotification(taskId);
        await NotificationService.instance.showTaskCompleted(taskId, task.title);
        debugPrint('✅ Task $taskId marked as complete from notification');
      }
    } catch (e) {
      debugPrint('❌ Error marking task as done: $e');
    }
  } else if (response.actionId == 'snooze') {
    debugPrint('⏰ Snooze action triggered for task $taskId');
    // Reschedule notification 10 minutes later
    try {
      final repo = TaskRepository();
      final task = await repo.getTaskById(taskId);
      if (task != null && task.dueDate != null) {
        final newDueDate = DateTime.now().add(const Duration(minutes: 10));
        await repo.updateTask(task.copyWith(dueDate: newDueDate));
        await NotificationService.instance.scheduleNotification(
          taskId,
          task.title,
          task.description,
          when: newDueDate,
          priority: task.priority,
          repeatRule: task.repeatRule,
        );
        debugPrint('⏰ Task $taskId snoozed for 10 minutes - new time: $newDueDate');
      }
    } catch (e) {
      debugPrint('❌ Error snoozing task: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Task Mania: Starting app initialization...');

  // Request critical permissions for background notifications
  debugPrint('🔐 Requesting permissions for persistent notifications...');
  await PermissionService.requestAllPermissions();

  // Initialize notification service with enhanced features
  debugPrint('📱 Initializing notification service...');
  await NotificationService.instance.init(onTap: _onNotificationTap);
  
  // Initialize background service for persistent notifications
  debugPrint('🔄 Initializing background notification service...');
  await BackgroundTaskService.instance.initialize();
  
  // Load tasks
  debugPrint('📋 Loading tasks...');
  final taskProvider = TaskProvider();
  await taskProvider.loadTasks();

  // Initialize background service (starts foreground service)
  debugPrint('🚀 Initializing background task service...');
  await BackgroundTaskService.instance.initialize();

  // Reschedule all pending notifications
  // This ensures notifications persist after:
  // - App restart
  // - Device reboot
  // - App force-stop
  // - App removed from RAM
  debugPrint('⏰ Rescheduling all pending notifications...');
  await NotificationRescheduleService.instance.rescheduleAllNotifications();

  debugPrint('✅ Task Mania: Initialization complete!');
  debugPrint('📱 Notifications will work even when app is closed');
  debugPrint('🔋 Notifications will work when screen is off');
  debugPrint('💾 Notifications will work when app is removed from RAM');
  debugPrint('🔄 Notifications will work after device reboot');
  debugPrint('⏰ Task tracking service is running in background');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const App(),
    ),
  );
}




class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    const seed = Color(0xFF6C63FF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Mania',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00BC8C),
          foregroundColor: Colors.white,
        ),
        snackBarTheme:
        const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00E0B7),
          foregroundColor: Colors.black,
        ),
        snackBarTheme:
        const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
