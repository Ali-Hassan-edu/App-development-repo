import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/profile_avatar.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  static const primaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final notifAsync = ref.watch(userNotificationsProvider(user.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: ProfileAvatar(
              userId: user.id,
              userName: user.name,
              radius: 18,
            ),
          ),
        ),
        title: const Text('Admin Alerts',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Read All button — only when there are unread notifications
          notifAsync.whenOrNull(
                data: (notifications) {
                  final unread = notifications.where((n) => !n.isRead).length;
                  if (unread == 0) return null;
                  return TextButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(notificationRepositoryProvider)
                            .markAllAsRead(user.id);
                        // Force refresh stream so UI updates immediately
                        ref.invalidate(userNotificationsProvider(user.id));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ All notifications marked as read'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to mark as read: $e'),
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
            onPressed: () => ref.invalidate(userNotificationsProvider(user.id)),
          ),
        ],
      ),
      body: notifAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
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
                        ? 'Check your internet and try again.'
                        : (isTimeout
                            ? 'The server is taking too long to respond.'
                            : 'Error: $e'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(userNotificationsProvider(user.id)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Alerts'),
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
          final unreadCount = notifications.where((n) => !n.isRead).length;
          final completedCount = notifications
              .where((n) => n.type == NotificationType.taskCompleted)
              .length;

          return Column(
            children: [
              Container(
                color: primaryColor,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        label: 'Total',
                        count: notifications.length.toString(),
                        icon: Icons.notifications_rounded,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Unread',
                        count: unreadCount.toString(),
                        icon: Icons.mark_email_unread_rounded,
                        color: unreadCount > 0
                            ? Colors.red.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Completed',
                        count: completedCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.green.withOpacity(0.25),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.07),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.inbox_rounded,
                                  size: 64, color: primaryColor),
                            ),
                            const SizedBox(height: 24),
                            const Text('No Notifications Yet',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 8),
                            const Text(
                                'Task completions and alerts\nwill appear here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(userNotificationsProvider(user.id));
                          // Small delay so the user sees the spinner
                          await Future.delayed(const Duration(milliseconds: 500));
                        },
                        color: primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return Dismissible(
                              key: Key(notification.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(18)),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 26),
                              ),
                              confirmDismiss: (_) async {
                                try {
                                  await ref
                                      .read(notificationRepositoryProvider)
                                      .removeNotification(notification.id);
                                  ref.invalidate(userNotificationsProvider(user.id));
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
                              child: _AdminNotificationCard(
                                notification: notification,
                                onMarkAsRead: () async {
                                  try {
                                    await ref
                                        .read(notificationRepositoryProvider)
                                        .markAsRead(notification.id);
                                    ref.invalidate(userNotificationsProvider(user.id));
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
                                onDelete: () async {
                                  try {
                                    await ref
                                        .read(notificationRepositoryProvider)
                                        .removeNotification(notification.id);
                                    ref.invalidate(userNotificationsProvider(user.id));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Notification deleted'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
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
                                  }
                                },
                              ),
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

class _SummaryPill extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  const _SummaryPill(
      {required this.label,
      required this.count,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _AdminNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const _AdminNotificationCard(
      {required this.notification,
      required this.onMarkAsRead,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        notification.type == NotificationType.taskCompleted;
    final accentColor =
        isCompleted ? const Color(0xFF2E7D32) : const Color(0xFF0D47A1);
    final iconData = isCompleted
        ? Icons.check_circle_outline_rounded
        : Icons.notifications_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade100
                : accentColor.withOpacity(0.3),
            width: notification.isRead ? 1 : 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: notification.isRead ? null : onMarkAsRead,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(iconData, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  fontSize: 15),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (!notification.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.message,
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Text(
                        DateFormat('MMM dd, yyyy • h:mm a')
                            .format(notification.timestamp),
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close,
                    size: 16, color: Colors.grey.shade400),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
