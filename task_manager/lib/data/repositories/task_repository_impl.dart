import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/constants.dart';
import '../../core/services/sync_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SupabaseClient _supabase;
  final SyncService _syncService;

  TaskRepositoryImpl(this._supabase, this._syncService);

  @override
  Future<List<TaskEntity>> getTasks() async {
    final currentAdminId = _supabase.auth.currentUser?.id;
    if (currentAdminId == null) return [];

    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('admin_id', currentAdminId)
          .order('createdAt', ascending: false);

      return (response as List).map((data) => _mapToEntity(data)).toList();
    } catch (e) {
      print('Offline fallback getting tasks: $e');
      final prefs = await SharedPreferences.getInstance();
      final cacheStr = prefs.getString('tasks_cache_admin_$currentAdminId');
      if (cacheStr != null) {
        return (json.decode(cacheStr) as List).map((data) => _mapToEntity(data)).toList();
      }
      return [];
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks() async* {
    final currentAdminId = _supabase.auth.currentUser?.id;
    if (currentAdminId == null) {
      yield [];
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'tasks_cache_admin_$currentAdminId';

    final cacheStr = prefs.getString(cacheKey);
    if (cacheStr != null) {
      try {
        final List decoded = json.decode(cacheStr);
        yield decoded.map((e) => _mapToEntity(e)).toList();
      } catch (_) {}
    }

    try {
      yield* _supabase
          .from('tasks')
          .stream(primaryKey: ['id'])
          .order('createdAt', ascending: false)
          .map((snapshot) {
            final adminTasksData = snapshot
                .where((data) => data['admin_id'] == currentAdminId)
                .toList();
            prefs.setString(cacheKey, json.encode(adminTasksData));
            return adminTasksData.map((data) => _mapToEntity(data)).toList();
          }).handleError((error) {
            print('Offline or Stream error: $error');
          });
    } catch (e) {
      print('Error starting stream: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasksByUserId(String userId) async* {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'tasks_cache_user_$userId';

    final cacheStr = prefs.getString(cacheKey);
    if (cacheStr != null) {
      try {
        final List decoded = json.decode(cacheStr);
        yield decoded.map((e) => _mapToEntity(e)).toList();
      } catch (_) {}
    }

    try {
      yield* _supabase
          .from('tasks')
          .stream(primaryKey: ['id'])
          .eq('assignedToId', userId)
          .order('createdAt', ascending: false)
          .map((snapshot) {
            prefs.setString(cacheKey, json.encode(snapshot));
            return snapshot.map((data) => _mapToEntity(data)).toList();
          }).handleError((error) {
            print('Offline error watching tasks by user: $error');
          });
    } catch (e) {
      print('Error watching tasks by user: $e');
      yield* Stream.fromFuture(getTasksByUserId(userId));
    }
  }

  @override
  Future<List<TaskEntity>> getTasksByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('assignedToId', userId)
          .order('createdAt', ascending: false);

      return (response as List).map((data) => _mapToEntity(data)).toList();
    } catch (e) {
      print('Offline fallback getting tasks by user: $e');
      final prefs = await SharedPreferences.getInstance();
      final cacheStr = prefs.getString('tasks_cache_user_$userId');
      if (cacheStr != null) {
        return (json.decode(cacheStr) as List).map((data) => _mapToEntity(data)).toList();
      }
      return [];
    }
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    String? assignedToId = task.assignedToId;
    if (assignedToId.startsWith('local_')) {
      assignedToId = null;
    }

    final currentAdminId = _supabase.auth.currentUser?.id;

    final payload = {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'dueDate': task.dueDate.toIso8601String(),
      'status': task.status,
      'assignedToId': assignedToId,
      'assignedToName': task.assignedToName,
      'completedAt': task.completedAt?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'admin_id': currentAdminId,
    };

    try {
      await _supabase.from('tasks').insert(payload);
    } catch (e) {
      await _syncService.queueAction('create_task', payload);
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final payload = {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.toIso8601String(),
    };

    final numericId = int.tryParse(task.id);
    try {
      await _supabase.from('tasks').update({
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
      }).eq('id', numericId ?? task.id);
    } catch (e) {
      print('Offline updating task: $e');
      await _syncService.queueAction('update_task', payload);
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String status) async {
    final completedAt = status == AppConstants.statusCompleted
        ? DateTime.now().toIso8601String()
        : null;

    final payload = {
      'taskId': taskId,
      'status': status,
      'completedAt': completedAt,
    };

    final numericId = int.tryParse(taskId);
    try {
      await _supabase.from('tasks').update({
        'status': status,
        'completedAt': completedAt,
      }).eq('id', numericId ?? taskId);
    } catch (e) {
      print('Offline updating task status: $e');
      await _syncService.queueAction('update_task_status', payload);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final numericId = int.tryParse(taskId);
    try {
      await _supabase.from('tasks').delete().eq('id', numericId ?? taskId);
    } catch (e) {
      print('Offline deleting task: $e');
      await _syncService.queueAction('delete_task', {'taskId': taskId});
    }
  }

  TaskEntity _mapToEntity(Map<String, dynamic> data) {
    return TaskEntity(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'Medium',
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'])
          : DateTime.now(),
      status: data['status'] ?? 'Pending',
      assignedToId: data['assignedToId'] ?? '',
      assignedToName: data['assignedToName'],
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      adminId: data['admin_id'],
    );
  }
}
