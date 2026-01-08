import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../../models/ledger_entry.dart';

class LedgerDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<void> insert(LedgerEntry entry) async {
    final db = await _db;
    await db.insert(
      'ledger_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(String id) async {
    final db = await _db;
    await db.delete('ledger_entries', where: 'id=?', whereArgs: [id]);
  }

  Future<List<LedgerEntry>> getByCustomer(String customerId) async {
    final db = await _db;
    final rows = await db.query(
      'ledger_entries',
      where: 'customerId=?',
      whereArgs: [customerId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(LedgerEntry.fromMap).toList();
  }

  /// Outstanding balance:
  /// debit increases balance
  /// credit/payment decreases balance
  Future<double> getBalance(String customerId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(
          CASE 
            WHEN type='debit' THEN amount
            ELSE -amount
          END
        ), 0) AS bal
      FROM ledger_entries
      WHERE customerId=?
    ''', [customerId]);

    final bal = rows.isNotEmpty ? rows.first['bal'] : 0;
    return (bal is num) ? bal.toDouble() : 0.0;
  }
}
