import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../data/local/db/app_database.dart';

class BackupService {
  static const String _folderName = 'SmartPOSBackups';
  static const int _keepLast = 7;

  // Auto backup throttle
  static const int _minAutoBackupMinutes = 60;
  static const String _prefsKeyLastAutoBackupMs = 'last_auto_backup_ms';

  /// ✅ REQUIRED TABLES (from your PDF)
  static const List<String> tables = [
    'products',
    'sales',
    'customers',
    'ledger',
  ];

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<Directory> _backupDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final backup = Directory('${dir.path}/$_folderName');
    if (!await backup.exists()) {
      await backup.create(recursive: true);
    }
    return backup;
  }

  /// ✅ LIST LOCAL BACKUPS (latest first)
  Future<List<File>> listLocalBackups() async {
    final dir = await _backupDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.json'))
        .toList();

    files.sort((a, b) {
      final am = a.lastModifiedSync().millisecondsSinceEpoch;
      final bm = b.lastModifiedSync().millisecondsSinceEpoch;
      return bm.compareTo(am);
    });

    return files;
  }

  /// ✅ MANUAL BACKUP (always creates)
  Future<String> createLocalBackup({String reason = 'manual'}) async {
    final db = await _db;
    final now = DateTime.now();

    final payload = <String, dynamic>{
      'app': 'SmartPOS',
      'version': 1,
      'reason': reason,
      'createdAtMs': now.millisecondsSinceEpoch,
      'createdAtIso': now.toIso8601String(),
      'tables': <String, dynamic>{},
    };

    for (final t in tables) {
      final exists = await _tableExists(db, t);
      if (!exists) {
        payload['tables'][t] = [];
        continue;
      }

      final rows = await db.query(t);
      payload['tables'][t] = rows;
    }

    final dir = await _backupDir();
    final fileName = 'SmartPOS_backup_${_fmt(now)}_${reason.toLowerCase()}.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );

    await _cleanupOldBackups(keepLast: _keepLast);
    return file.path;
  }

  /// ✅ AUTO BACKUP (only if enough time passed)
  Future<String?> autoBackupIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_prefsKeyLastAutoBackupMs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    final diffMin = (now - last) / (1000 * 60);
    if (diffMin < _minAutoBackupMinutes) return null;

    final path = await createLocalBackup(reason: 'auto');
    await prefs.setInt(_prefsKeyLastAutoBackupMs, now);
    return path;
  }

  /// ✅ DELETE A BACKUP FILE
  Future<void> deleteBackupFile(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }

  /// ✅ RESTORE BACKUP (REPLACE DATA)
  Future<void> restoreFromBackupFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw 'Backup file not found';
    }

    final raw = await file.readAsString();
    final json = jsonDecode(raw);

    if (json is! Map<String, dynamic>) throw 'Invalid backup file';
    final tablesData = json['tables'];
    if (tablesData is! Map<String, dynamic>) throw 'Invalid backup structure';

    final db = await _db;

    await db.transaction((txn) async {
      for (final t in tables) {
        final rows = tablesData[t];

        // If table missing in backup => skip
        if (rows == null || rows is! List) continue;

        // Clear table
        await txn.delete(t);

        // Insert rows
        final batch = txn.batch();
        for (final row in rows) {
          if (row is Map) {
            batch.insert(t, Map<String, Object?>.from(row));
          }
        }
        await batch.commit(noResult: true);
      }
    });
  }

  Future<void> _cleanupOldBackups({required int keepLast}) async {
    final files = await listLocalBackups();
    if (files.length <= keepLast) return;

    final toDelete = files.sublist(keepLast);
    for (final f in toDelete) {
      try {
        await f.delete();
      } catch (_) {}
    }
  }

  static String _fmt(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}_${two(d.hour)}-${two(d.minute)}';
  }

  Future<bool> _tableExists(Database db, String table) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return rows.isNotEmpty;
  }
}
