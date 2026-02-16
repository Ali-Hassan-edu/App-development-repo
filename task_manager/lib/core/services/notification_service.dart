import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String userId; // For whom the notification is intended

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    required this.userId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? userId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'userId': userId,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      isRead: json['isRead'] ?? false,
      userId: json['userId'],
    );
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
  taskAssigned,
  taskCompleted,
}

class NotificationServiceNotifier
    extends StateNotifier<List<NotificationModel>> {
  NotificationServiceNotifier() : super([]);

  List<NotificationModel> get notifications => state;

  List<NotificationModel> getUserNotifications(String userId) {
    print('SERVICE DEBUG: Getting notifications for user: $userId');
    print('SERVICE DEBUG: Total notifications in service: ${state.length}');
    for (var notif in state) {
      print(
        'SERVICE DEBUG: Checking notification - Title: ${notif.title}, User: ${notif.userId}, Type: ${notif.type}',
      );
    }
    final userNotifications =
        state.where((notification) => notification.userId == userId).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    print(
      'SERVICE DEBUG: Found ${userNotifications.length} notifications for user $userId',
    );
    for (var notif in userNotifications) {
      print(
        'SERVICE DEBUG: Returning notification - Title: ${notif.title}, User: ${notif.userId}, Type: ${notif.type}',
      );
    }
    return userNotifications;
  }

  List<NotificationModel> getUnreadNotifications(String userId) {
    return state
        .where(
          (notification) =>
              notification.userId == userId && !notification.isRead,
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int getUnreadCount(String userId) {
    print('SERVICE DEBUG: Getting unread count for user: $userId');
    print('SERVICE DEBUG: Total notifications in service: ${state.length}');
    final unreadCount = state
        .where(
          (notification) =>
              notification.userId == userId && !notification.isRead,
        )
        .length;
    print('SERVICE DEBUG: Unread count for user $userId: $unreadCount');
    return unreadCount;
  }

  void addNotification(NotificationModel notification) {
    print(
      'SERVICE DEBUG: Adding notification: ${notification.title} for user: ${notification.userId}',
    );
    print('SERVICE DEBUG: Notification type: ${notification.type}');
    print(
      'SERVICE DEBUG: Current notification count before adding: ${state.length}',
    );
    final newState = List<NotificationModel>.from(state)..add(notification);
    state = newState;
    print('SERVICE DEBUG: Total notifications after adding: ${state.length}');
    print('SERVICE DEBUG: All notifications now:');
    for (var notif in state) {
      print(
        'SERVICE DEBUG: - Title: ${notif.title}, User: ${notif.userId}, Type: ${notif.type}',
      );
    }
    print('SERVICE DEBUG: Listeners notified');
  }

  void markAsRead(String notificationId) {
    final index = state.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final newState = List<NotificationModel>.from(state);
      newState[index] = newState[index].copyWith(isRead: true);
      state = newState;
    }
  }

  void markAllAsRead(String userId) {
    final newState = state.asMap().entries.map((entry) {
      final notification = entry.value;
      if (notification.userId == userId && !notification.isRead) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    state = newState;
  }

  void removeNotification(String notificationId) {
    final newState = state
        .where((notification) => notification.id != notificationId)
        .toList();
    state = newState;
  }

  void clearAllNotifications(String userId) {
    final newState = state
        .where((notification) => notification.userId != userId)
        .toList();
    state = newState;
  }
}
