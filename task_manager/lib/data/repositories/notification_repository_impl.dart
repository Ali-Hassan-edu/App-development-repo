import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/sync_service.dart';

class NotificationRepositoryImpl {
  final SupabaseClient _supabase;
  final SyncService _syncService;

  NotificationRepositoryImpl(this._supabase, this._syncService);

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final payload = {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'is_read': false,
    };
    try {
      await _supabase.from('notifications').insert(payload);
    } catch (e) {
      print('Offline creating notification: $e');
      await _syncService.queueAction('create_notification', payload);
    }
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final mapped = (response as List).map((row) => _mapRowToModel(row)).toList();
      
      // Cache the result
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('notifications_cache_$userId', json.encode(response));
      
      return mapped;
    } catch (e) {
      print('Offline getting notifications: $e');
      final prefs = await SharedPreferences.getInstance();
      final cacheStr = prefs.getString('notifications_cache_$userId');
      if (cacheStr != null) {
        return (json.decode(cacheStr) as List).map((row) => _mapRowToModel(row)).toList();
      }
      return [];
    }
  }

  Stream<List<NotificationModel>> watchNotifications(String userId) async* {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'notifications_cache_$userId';

    final cacheStr = prefs.getString(cacheKey);
    if (cacheStr != null) {
      try {
        final List decoded = json.decode(cacheStr);
        yield decoded.map((e) => _mapRowToModel(e)).toList();
      } catch (_) {}
    }

    try {
      yield* _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map((snapshot) {
            prefs.setString(cacheKey, json.encode(snapshot));
            return snapshot.map((data) => _mapRowToModel(data)).toList();
          }).handleError((error) {
            print('Offline error watching notifications: $error');
          });
    } catch (e) {
      print('Error watching notifications: $e');
      yield* Stream.fromFuture(getNotifications(userId));
    }
  }

  NotificationModel _mapRowToModel(Map<String, dynamic> row) {
    return NotificationModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      message: row['message'] ?? '',
      timestamp: DateTime.parse(row['created_at']),
      type: _mapType(row['type']),
      isRead: row['is_read'] ?? false,
      userId: row['user_id'],
    );
  }

  Future<void> markAsRead(String id) async {
    final numericId = int.tryParse(id);
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', numericId ?? id);
    } catch (e) {
      print('Offline marking notification read: $e');
      await _syncService.queueAction('mark_notification_read', {'id': id});
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      print('Offline marking all notifications read: $e');
      await _syncService.queueAction('mark_all_notifications_read', {'user_id': userId});
    }
  }

  Future<void> removeNotification(String id) async {
    final numericId = int.tryParse(id);
    try {
      await _supabase.from('notifications').delete().eq('id', numericId ?? id);
    } catch (e) {
      print('Offline removing notification: $e');
      await _syncService.queueAction('delete_notification', {'id': id});
    }
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
