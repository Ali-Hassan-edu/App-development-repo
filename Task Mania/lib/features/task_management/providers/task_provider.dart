import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();
  final NotificationService _notifs = NotificationService.instance;

  List<Task> _tasks = [];
  Map<int, List<Subtask>> _subtasks = {};
  bool _loading = false;

  List<Task> get tasks => _tasks;
  Map<int, List<Subtask>> get subtasks => _subtasks;
  bool get isLoading => _loading;

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();
    _tasks = await _repo.getTasks();
    _subtasks = await _repo.getAllSubtasks();
    _loading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task, {List<Subtask>? subs}) async {
    final id = await _repo.insertTask(task);
    final created = task.copyWith(id: id);
    _tasks.add(created);

    // subtasks
    if (subs != null && subs.isNotEmpty) {
      for (final s in subs) {
        await _repo.insertSubtask(s.copyWith(taskId: id));
      }
      _subtasks[id] = subs.map((s) => s.copyWith(taskId: id)).toList();
    }

    // reminder
    if (created.dueDate != null &&
        !created.isCompleted &&
        created.dueDate!.isAfter(DateTime.now())) {
      await _notifs.scheduleNotification(
        id,
        created.title,
        created.description,
        when: created.dueDate!,
        priority: created.priority,
        repeatRule: created.repeatRule,
      );
    }

    notifyListeners();
  }

  Future<void> updateTask(Task task, {List<Subtask>? subs}) async {
    if (task.id == null) return;

    await _repo.updateTask(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;

    if (subs != null) {
      await _repo.replaceSubtasksForTask(task.id!, subs);
      _subtasks[task.id!] =
          subs.map((s) => s.copyWith(taskId: task.id!)).toList();
    }

    // re-schedule notification for edited task
    await _notifs.cancelNotification(task.id!);
    if (task.dueDate != null &&
        !task.isCompleted &&
        task.dueDate!.isAfter(DateTime.now())) {
      await _notifs.scheduleNotification(
        task.id!,
        task.title,
        task.description,
        when: task.dueDate!,
        priority: task.priority,
        repeatRule: task.repeatRule,
      );
    }

    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _repo.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    _subtasks.remove(id);
    await _notifs.cancelNotification(id);
    notifyListeners();
  }

  /// Toggle main task completion
  Future<void> toggleComplete(Task task) async {
    if (task.id == null) return;

    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repo.updateTask(updated);

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = updated;
    }

    if (updated.isCompleted) {
      // stop reminder + show "completed" notification
      await _notifs.cancelNotification(updated.id!);
      await _notifs.showTaskCompleted(updated.id!, updated.title);
    } else {
      // un-complete => re-schedule reminder if future date hai
      if (updated.dueDate != null &&
          updated.dueDate!.isAfter(DateTime.now())) {
        await _notifs.scheduleNotification(
          updated.id!,
          updated.title,
          updated.description,
          when: updated.dueDate!,
          priority: updated.priority,
          repeatRule: updated.repeatRule,
        );
      }
    }

    notifyListeners();
  }

  /// Toggle subtask completion
  void toggleSubtaskDone(Subtask subtask) {
    final updated = subtask.copyWith(isDone: !subtask.isDone);
    _repo.updateSubtask(updated).then((_) {
      final list = _subtasks[subtask.taskId];
      if (list != null) {
        final index = list.indexWhere((s) => s.id == subtask.id);
        if (index != -1) {
          list[index] = updated;
          notifyListeners();
        }
      }
    });
  }

  double progressForTask(int taskId) {
    final list = _subtasks[taskId];
    if (list == null || list.isEmpty) return 0;
    final done = list.where((s) => s.isDone).length;
    return done / list.length;
  }
}
