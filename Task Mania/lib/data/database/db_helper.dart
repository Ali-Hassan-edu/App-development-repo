import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const String taskTable = 'tasks';
  static const String subtaskTable = 'subtasks';

  DBHelper._();
  static final DBHelper instance = DBHelper._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'task_manager.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $taskTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        dueDate INTEGER,
        isCompleted INTEGER NOT NULL,
        repeatRule TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $subtaskTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        FOREIGN KEY (taskId) REFERENCES $taskTable(id) ON DELETE CASCADE
      )
    ''');
  }
}