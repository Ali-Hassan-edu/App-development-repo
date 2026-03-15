import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../../core/services/notification_service.dart';

class UserNotificationsScreen extends ConsumerWidget {
  final String userId;
  const UserNotificationsScreen({super.key, required this.userId});

  static const primaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Failed to load notifications:\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        data: (notifications) {
          final unreadCount = notifications.where((n) => !n.isRead).length;

          return Column(
            children: [
              if (unreadCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => ref
                          .read(notificationRepositoryProvider)
                          .markAllAsRead(userId),
                      child: const Text(
                        'Read All',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 80,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "You'll be notified when tasks are assigned.",
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: notifications.length,
                        itemBuilder: (context, i) {
                          final n = notifications[i];
                          return _NotifCard(
                            notification: n,
                            onTap: () => ref
                                .read(notificationRepositoryProvider)
                                .markAsRead(n.id),
                            onDismiss: () => ref
                                .read(notificationRepositoryProvider)
                                .removeNotification(n.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  static const primaryColor = Color(0xFF0D47A1);

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.taskAssigned:
        return primaryColor;
      case NotificationType.taskCompleted:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.info:
        return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.taskAssigned:
        return Icons.assignment_rounded;
      case NotificationType.taskCompleted:
        return Icons.check_circle_rounded;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.success:
        return Icons.check_circle_outline_rounded;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : _typeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade100
                  : _typeColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              fontSize: 14,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM dd · hh:mm a')
                          .format(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
