import 'package:supabase_flutter/supabase_flutter.dart';
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
      return (response as List).map((data) => _mapToEntity(data)).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('createdAt', ascending: false)
        .map((snapshot) => snapshot.map((data) => _mapToEntity(data)).toList());
  }

  @override
  Stream<List<TaskEntity>> watchTasksByUserId(String userId) {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('assignedToId', userId)
        .order('createdAt', ascending: false)
        .map((snapshot) => snapshot.map((data) => _mapToEntity(data)).toList());
  }

  @override
  Future<List<TaskEntity>> getTasksByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('assignedToId', userId);
      return (response as List).map((data) => _mapToEntity(data)).toList();
    } catch (e) {
      print('Error getting tasks by user: $e');
      return [];
    }
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    String? assignedToId = task.assignedToId;
    if (assignedToId.startsWith('local_')) assignedToId = null;

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
      print('Error updating task status: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  TaskEntity _mapToEntity(Map<String, dynamic> data) {
    return TaskEntity(
      id: data['id'] ?? '',
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
    );
  }
}
