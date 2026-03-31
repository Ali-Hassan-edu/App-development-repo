import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile_avatar.dart';

class UserNotificationsScreen extends ConsumerWidget {
  final String userId;
  const UserNotificationsScreen({super.key, required this.userId});

  static const primaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final notificationsAsync = ref.watch(userNotificationsProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: ProfileAvatar(
              userId: user?.id ?? '',
              userName: user?.name ?? 'User',
              radius: 18,
            ),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Read All button — only when there are unread notifications
          notificationsAsync.whenOrNull(
                data: (notifications) {
                  final unread = notifications.where((n) => !n.isRead).length;
                  if (unread == 0) return null;
                  return TextButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(notificationRepositoryProvider)
                            .markAllAsRead(userId);
                        ref.invalidate(userNotificationsProvider(userId));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ All marked as read'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed: $e'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Read All',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  );
                },
              ) ??
              const SizedBox.shrink(),
          // Manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(userNotificationsProvider(userId)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final errStr = e.toString();
          final isOffline = errStr.contains('SocketException') || errStr.contains('host lookup');
          final isTimeout = errStr.contains('timedOut') || errStr.contains('timeout');

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline
                        ? Icons.cloud_off_rounded
                        : (isTimeout ? Icons.timer_off_outlined : Icons.error_outline),
                    size: 64,
                    color: isOffline ? Colors.orange : (isTimeout ? Colors.blue : Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isOffline
                        ? 'You are offline'
                        : (isTimeout ? 'Connection is slow' : 'Something went wrong'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOffline
                        ? 'Check your internet connection to see new alerts.'
                        : (isTimeout
                            ? 'We are having trouble reaching the server.'
                            : 'Error: $e'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(userNotificationsProvider(userId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        data: (notifications) {
          return Column(
            children: [
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
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(userNotificationsProvider(userId));
                          await Future.delayed(const Duration(milliseconds: 500));
                        },
                        color: primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: notifications.length,
                          itemBuilder: (context, i) {
                            final n = notifications[i];
                            return _NotifCard(
                              notification: n,
                              onTap: () async {
                                if (n.isRead) return;
                                try {
                                  await ref
                                      .read(notificationRepositoryProvider)
                                      .markAsRead(n.id);
                                  ref.invalidate(userNotificationsProvider(userId));
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed: $e'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              onDismiss: () async {
                                try {
                                  await ref
                                      .read(notificationRepositoryProvider)
                                      .removeNotification(n.id);
                                  ref.invalidate(userNotificationsProvider(userId));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notification deleted'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                  return true;
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Delete failed: $e'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                  return false;
                                }
                              },
                            );
                          },
                        ),
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
  final Future<bool> Function() onDismiss;

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
      confirmDismiss: (_) => onDismiss(),
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
