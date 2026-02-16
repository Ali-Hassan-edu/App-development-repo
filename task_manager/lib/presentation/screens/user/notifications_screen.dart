import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'NOTIFICATIONS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              ref
                  .read(notificationServiceProvider.notifier)
                  .markAllAsRead(user.id);
            },
          ),
        ],
      ),
      body: NotificationList(userId: user.id),
    );
  }
}

class NotificationList extends ConsumerWidget {
  final String userId;

  const NotificationList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: Building notification list for user: $userId');
    final allNotifications = ref.watch(notificationServiceProvider);
    print('DEBUG: Total notifications in service: ${allNotifications.length}');
    for (var notif in allNotifications) {
      print(
        'DEBUG: Service notification - Title: ${notif.title}, User: ${notif.userId}, Type: ${notif.type}',
      );
    }
    final notifications =
        allNotifications
            .where((notification) => notification.userId == userId)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    print(
      'DEBUG: Found ${notifications.length} notifications for user $userId',
    );
    for (var notification in notifications) {
      print(
        'DEBUG: User notification - Title: ${notification.title}, User: ${notification.userId}, Read: ${notification.isRead}',
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Color(0xFF0D47A1)),
            SizedBox(height: 24),
            Text(
              'No new notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D47A1),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          onMarkAsRead: () {
            ref
                .read(notificationServiceProvider.notifier)
                .markAsRead(notification.id);
          },
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    Color getIconColor() {
      switch (notification.type) {
        case NotificationType.success:
          return Colors.green;
        case NotificationType.warning:
          return Colors.orange;
        case NotificationType.error:
          return Colors.red;
        case NotificationType.info:
        case NotificationType.taskAssigned:
        case NotificationType.taskCompleted:
          return const Color(0xFF0D47A1);
      }
    }

    IconData getIcon() {
      switch (notification.type) {
        case NotificationType.success:
          return Icons.check_circle;
        case NotificationType.warning:
          return Icons.warning;
        case NotificationType.error:
          return Icons.error;
        case NotificationType.info:
          return Icons.info;
        case NotificationType.taskAssigned:
          return Icons.assignment;
        case NotificationType.taskCompleted:
          return Icons.check_circle_outline;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFF0D47A1).withValues(alpha: 0.1)
              : getIconColor().withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onMarkAsRead,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: getIconColor().withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: getIconColor().withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(getIcon(), color: getIconColor(), size: 28),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: const Color(0xFF0D47A1),
            decoration: notification.isRead ? TextDecoration.lineThrough : null,
            decorationThickness: notification.isRead ? 2 : 0,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: const Color(0xFF0D47A1).withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: notification.isRead
                    ? TextDecoration.lineThrough
                    : null,
                decorationThickness: notification.isRead ? 1 : 0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'MMM dd, yyyy • hh:mm a',
                  ).format(notification.timestamp),
                  style: TextStyle(
                    color: const Color(0xFF0D47A1).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getIconColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
