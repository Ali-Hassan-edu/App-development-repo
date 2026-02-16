import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/constants.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SupabaseClient _supabase;

  TaskRepositoryImpl(this._supabase);

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      final response = await _supabase.from('tasks').select();
      return (response as List)
          .map((data) => _mapToEntity(data['id'], data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('createdAt', ascending: false)
        .map((snapshot) {
          return snapshot
              .map((data) => _mapToEntity(data['id'] as String, data))
              .toList();
        });
  }

  @override
  Stream<List<TaskEntity>> watchTasksByUserId(String userId) {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('assignedToId', userId)
        .order('createdAt', ascending: false)
        .map((snapshot) {
          return snapshot
              .map((data) => _mapToEntity(data['id'] as String, data))
              .toList();
        });
  }

  @override
  Future<List<TaskEntity>> getTasksByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('assignedToId', userId);
      return (response as List)
          .map((data) => _mapToEntity(data['id'], data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    try {
      // For local users, set assignedToId to NULL to bypass foreign key constraint
      String? assignedToId = task.assignedToId;

      if (assignedToId.startsWith('local_')) {
        assignedToId = null; // Bypass foreign key constraint
        print('Bypassing foreign key for local user');
      }

      await _supabase.from('tasks').insert({
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
      });

      print('Task created successfully');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _supabase
          .from('tasks')
          .update({
            'status': status,
            'completedAt': status == AppConstants.statusCompleted
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', taskId);
    } catch (e) {
      print('Update failed: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      print('Delete failed: $e');
    }
  }

  TaskEntity _mapToEntity(String id, Map<String, dynamic> data) {
    return TaskEntity(
      id: id,
      title: data['title'],
      description: data['description'],
      priority: data['priority'],
      dueDate: DateTime.parse(data['dueDate']),
      status: data['status'],
      assignedToId: data['assignedToId'],
      assignedToName: data['assignedToName'],
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
}
