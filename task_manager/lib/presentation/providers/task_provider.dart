import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import 'providers.dart';

final tasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

final userTasksStreamProvider = StreamProvider.family<List<TaskEntity>, String>(
  (ref, userId) {
    return ref.watch(taskRepositoryProvider).watchTasksByUserId(userId);
  },
);

final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);

  return tasksAsync.when(
    data: (tasks) {
      return {
        'total': tasks.length,
        'completed': tasks.where((t) => t.status == 'Completed').length,
        'pending': tasks.where((t) => t.status == 'Pending').length,
        'inProgress': tasks.where((t) => t.status == 'In Progress').length,
        'overdue': tasks.where((t) => t.isOverdue).length,
      };
    },
    loading: () => {
      'total': 0,
      'completed': 0,
      'pending': 0,
      'inProgress': 0,
      'overdue': 0,
    },
    error: (_, __) => {
      'total': 0,
      'completed': 0,
      'pending': 0,
      'inProgress': 0,
      'overdue': 0,
    },
  );
});
