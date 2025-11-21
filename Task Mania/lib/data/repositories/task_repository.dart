import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';

class TaskRepository {
  final _dbHelper = DBHelper.instance;

  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return db.insert(DBHelper.taskTable, task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTask(Task task) async {
    if (task.id == null) throw Exception('Cannot update task: id is null');
    final db = await _dbHelper.database;
    return db.update(DBHelper.taskTable, task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return db.delete(DBHelper.taskTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DBHelper.taskTable, orderBy: 'dueDate ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(DBHelper.taskTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<int> insertSubtask(Subtask sub) async {
    final db = await _dbHelper.database;
    return db.insert(DBHelper.subtaskTable, sub.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> replaceSubtasksForTask(int taskId, List<Subtask> subs) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(DBHelper.subtaskTable, where: 'taskId = ?', whereArgs: [taskId]);
      for (final s in subs) {
        await txn.insert(DBHelper.subtaskTable, s.copyWith(taskId: taskId).toMap());
      }
    });
  }

  Future<int> updateSubtask(Subtask sub) async {
    if (sub.id == null) throw Exception('Cannot update subtask: id is null');
    final db = await _dbHelper.database;
    return db.update(DBHelper.subtaskTable, sub.toMap(), where: 'id = ?', whereArgs: [sub.id]);
  }

  Future<Map<int, List<Subtask>>> getAllSubtasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DBHelper.subtaskTable, orderBy: 'taskId ASC');

    final out = <int, List<Subtask>>{};
    for (final m in maps) {
      final s = Subtask.fromMap(m);
      out.putIfAbsent(s.taskId, () => []).add(s);
    }
    return out;
  }
}