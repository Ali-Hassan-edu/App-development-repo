import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/notification_service.dart';

class NotificationRepositoryImpl {
  final SupabaseClient _supabase;
  NotificationRepositoryImpl(this._supabase);

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'is_read': false,
    });
  }

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) {
              return NotificationModel(
                id: row['id'].toString(),
                title: row['title'] ?? '',
                message: row['message'] ?? '',
                timestamp: DateTime.parse(row['created_at']),
                type: _mapType(row['type']),
                isRead: row['is_read'] ?? false,
                userId: row['user_id'],
              );
            }).toList());
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> removeNotification(String id) async {
    await _supabase.from('notifications').delete().eq('id', id);
  }

  NotificationType _mapType(String? type) {
    switch (type) {
      case 'taskAssigned':
        return NotificationType.taskAssigned;
      case 'taskCompleted':
        return NotificationType.taskCompleted;
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      default:
        return NotificationType.info;
    }
  }
}
