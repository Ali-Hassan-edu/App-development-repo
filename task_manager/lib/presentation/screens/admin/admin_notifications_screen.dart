import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../../core/services/notification_service.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allNotifications = ref.watch(notificationServiceProvider);
    final notifications = allNotifications
        .where((n) => n.userId == user.id)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    const primaryColor = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'ADMIN NOTIFICATIONS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => ref.read(notificationServiceProvider.notifier).markAllAsRead(user.id),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: primaryColor),
                  SizedBox(height: 24),
                  Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primaryColor)),
                  SizedBox(height: 8),
                  Text('Task completions will appear here', style: TextStyle(fontSize: 14, color: primaryColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onMarkAsRead: () => ref.read(notificationServiceProvider.notifier).markAsRead(notification.id),
                  onDelete: () => ref.read(notificationServiceProvider.notifier).removeNotification(notification.id),
                );
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationType.taskCompleted:
        iconColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case NotificationType.taskAssigned:
        iconColor = const Color(0xFF0D47A1);
        iconData = Icons.assignment;
        break;
      default:
        iconColor = const Color(0xFF0D47A1);
        iconData = Icons.notifications;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? const Color(0xFF0D47A1).withOpacity(0.1) : iconColor.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.1),
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
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
          ),
          child: Icon(iconData, color: iconColor, size: 28),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: const Color(0xFF0D47A1),
            decoration: notification.isRead ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: const Color(0xFF0D47A1).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: notification.isRead ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(notification.timestamp),
                  style: TextStyle(
                    color: const Color(0xFF0D47A1).withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
          onPressed: onDelete,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
