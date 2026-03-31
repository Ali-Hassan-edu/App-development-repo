import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  final SupabaseClient _supabase;
  static const String _queueKey = 'offline_sync_queue';

  SyncService(this._supabase) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((results) {
      final bool isOnline = results.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        _processQueue();
      }
    });
  }

  Future<void> queueAction(String action, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_queueKey) ?? [];

    final newItem = {
      'action': action,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    queueJson.add(json.encode(newItem));
    await prefs.setStringList(_queueKey, queueJson);
    print('Queued offline action: $action');
  }

  Future<void> _processQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_queueKey) ?? [];

    if (queueJson.isEmpty) return;

    final List<String> pendingQueue = [];

    for (var itemStr in queueJson) {
      try {
        final item = json.decode(itemStr);
        final action = item['action'];
        final payload = item['payload'];

        switch (action) {
          // ── Task actions ──────────────────────────────────────────────
          case 'create_task':
            await _supabase.from('tasks').upsert(payload);
            break;

          case 'update_task_status':
            final mapped = <String, dynamic>{'status': payload['status']};
            if (payload['completedAt'] != null) {
              mapped['completedAt'] = payload['completedAt'];
            }
            await _supabase
                .from('tasks')
                .update(mapped)
                .eq('id', payload['taskId']);
            break;

          case 'update_task':
            await _supabase.from('tasks').update({
              'title': payload['title'],
              'description': payload['description'],
              'dueDate': payload['dueDate'],
            }).eq('id', payload['id']);
            break;

          case 'delete_task':
            await _supabase
                .from('tasks')
                .delete()
                .eq('id', payload['taskId']);
            break;

          // ── Notification actions ──────────────────────────────────────
          case 'create_notification':
            await _supabase.from('notifications').insert({
              'user_id': payload['user_id'],
              'title': payload['title'],
              'message': payload['message'],
              'type': payload['type'],
              'is_read': false,
            });
            break;

          case 'mark_notification_read':
            final nId = int.tryParse(payload['id'].toString());
            await _supabase
                .from('notifications')
                .update({'is_read': true})
                .eq('id', nId ?? payload['id']);
            break;

          case 'mark_all_notifications_read':
            await _supabase
                .from('notifications')
                .update({'is_read': true})
                .eq('user_id', payload['user_id']);
            break;

          case 'delete_notification':
            final nId = int.tryParse(payload['id'].toString());
            await _supabase
                .from('notifications')
                .delete()
                .eq('id', nId ?? payload['id']);
            break;

          default:
            print('Unknown sync action: $action');
        }
      } catch (e) {
        print('Sync error for action: $itemStr -> $e');
        pendingQueue.add(itemStr);
      }
    }

    await prefs.setStringList(_queueKey, pendingQueue);
    print('Processed queue. Remaining items: ${pendingQueue.length}');
  }
}
