import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../data/local/db/app_database.dart';
import 'backup_service.dart';

class RestoreService {
  Future<Database> get _db async => AppDatabase.instance.database;

  /// ✅ RESTORE from local backup JSON file path
  Future<void> restoreFromLocalBackupFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw 'Backup file not found';
    }

    final content = await file.readAsString();
    final json = jsonDecode(content);

    if (json is! Map<String, dynamic>) throw 'Invalid backup format';

    final tables = json['tables'];
    if (tables is! Map) throw 'Backup missing tables';

    final db = await _db;

    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys=OFF');

      for (final t in BackupService.tables) {
        final list = tables[t];
        if (list is! List) continue;

        final exists = await _tableExists(txn, t);
        if (!exists) continue;

        // full replace restore
        await txn.delete(t);

        final batch = txn.batch();
        for (final row in list) {
          if (row is Map) {
            batch.insert(
              t,
              Map<String, Object?>.from(row),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        await batch.commit(noResult: true);
      }

      await txn.execute('PRAGMA foreign_keys=ON');
    });
  }

  Future<bool> _tableExists(DatabaseExecutor db, String table) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return rows.isNotEmpty;
  }
}
