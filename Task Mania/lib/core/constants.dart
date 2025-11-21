class AppConstants {
  static const String appName = 'Taskly';
  static const String appVersion = '1.0.0';

  // Notification channels
  static const String notificationChannelId = 'task_channel_id';
  static const String notificationChannelName = 'Task Reminders';

  // Database constants
  static const String databaseName = 'task_manager.db';
  static const int databaseVersion = 1;

  // Priority options
  static const List<String> priorityOptions = ['Low', 'Medium', 'High'];

  // Repeat options
  static const List<String> repeatOptions = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
    'Mon,Wed,Fri',
    'Tue,Thu',
    'Weekdays',
    'Weekends'
  ];
}