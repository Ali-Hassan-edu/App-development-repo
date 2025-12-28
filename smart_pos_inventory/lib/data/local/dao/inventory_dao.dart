import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../../models/inventory_log.dart';

class InventoryDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<void> insertLog(InventoryLog log) async {
    final db = await _db;
    await db.insert('inventory_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<InventoryLog>> getLogs({String? productId}) async {
    final db = await _db;
    final rows = await db.query(
      'inventory_logs',
      where: productId == null ? null : 'productId=?',
      whereArgs: productId == null ? null : [productId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(InventoryLog.fromMap).toList();
  }
}
