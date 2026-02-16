import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks();
  Stream<List<TaskEntity>> watchTasks();
  Future<List<TaskEntity>> getTasksByUserId(String userId);
  Stream<List<TaskEntity>> watchTasksByUserId(String userId);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTaskStatus(String taskId, String status);
  Future<void> deleteTask(String taskId);
}
