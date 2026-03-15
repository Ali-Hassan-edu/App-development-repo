/// Push notification service stub
/// Real push notifications are handled by Firebase Cloud Messaging
/// In-app notifications are handled by NotificationServiceNotifier
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  Future<void> initialize() async {
    // Firebase Messaging handles push - no extra setup needed here
  }

  Future<void> showTaskAssigned({
    required String taskTitle,
    required String by,
  }) async {
    // In-app notification is added via NotificationServiceNotifier
    // FCM will handle real push when backend sends it
  }

  Future<void> showTaskCompleted({
    required String taskTitle,
    required String by,
  }) async {
    // In-app notification is added via NotificationServiceNotifier
  }

  Future<void> showWelcome({required String userName}) async {
    // Welcome notification shown in-app via NotificationServiceNotifier
  }
}