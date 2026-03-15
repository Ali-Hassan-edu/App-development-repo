import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType {
  info,
  success,
  warning,
  error,
  taskAssigned,
  taskCompleted,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String userId;

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
}

/// In-app notification state manager
class NotificationServiceNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationServiceNotifier() : super([]);

  List<NotificationModel> getUserNotifications(String userId) {
    return state
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int getUnreadCount(String userId) {
    return state.where((n) => n.userId == userId && !n.isRead).length;
  }

  void addNotification(NotificationModel notification) {
    state = [...state, notification];
  }

  void markAsRead(String notificationId) {
    state = state.map((n) {
      if (n.id == notificationId) return n.copyWith(isRead: true);
      return n;
    }).toList();
  }

  void markAllAsRead(String userId) {
    state = state.map((n) {
      if (n.userId == userId && !n.isRead) return n.copyWith(isRead: true);
      return n;
    }).toList();
  }

  void removeNotification(String notificationId) {
    state = state.where((n) => n.id != notificationId).toList();
  }

  void clearAllNotifications(String userId) {
    state = state.where((n) => n.userId != userId).toList();
  }
}
