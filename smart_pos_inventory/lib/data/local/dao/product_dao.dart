import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../../models/product.dart';

class ProductDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Product>> getAll() async {
    final db = await _db;
    final rows = await db.query('products', orderBy: 'updatedAt DESC');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('products', where: 'id=?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<void> insert(Product p) async {
    final db = await _db;
    await db.insert('products', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// ✅ NEW: Bulk Insert (Fast)
  Future<void> insertBulk(List<Product> products) async {
    if (products.isEmpty) return;

    final db = await _db;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final p in products) {
        batch.insert(
          'products',
          p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<void> update(Product p) async {
    final db = await _db;
    await db.update('products', p.toMap(), where: 'id=?', whereArgs: [p.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('products', where: 'id=?', whereArgs: [id]);
  }

  Future<void> updateStock(String id, int newStock, int updatedAt) async {
    final db = await _db;
    await db.update(
      'products',
      {'stock': newStock, 'updatedAt': updatedAt},
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
