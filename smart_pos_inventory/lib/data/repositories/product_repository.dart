// lib/data/repositories/product_repository.dart
import 'package:uuid/uuid.dart';

import '../local/dao/product_dao.dart';
import '../local/dao/inventory_dao.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductDao _dao;
  final InventoryDao _invDao;

  ProductRepository(this._dao, this._invDao);

  Future<List<Product>> getAll() => _dao.getAll();

  Future<void> add({
    required String name,
    String? sku,
    String? category,
    required double price,
    double? cost,
    int stock = 0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final p = Product(
      id: const Uuid().v4(),
      name: name.trim(),
      sku: (sku == null || sku.trim().isEmpty) ? null : sku.trim(),
      category: (category == null || category.trim().isEmpty) ? null : category.trim(),
      price: price,
      cost: cost,
      stock: stock,
      createdAt: now,
      updatedAt: now,
    );

    await _dao.insert(p);
  }

  /// ✅ BULK ADD (safe + robust)
  /// ✅ BULK ADD (SAFE)
  Future<void> addBulk(List<Map<String, dynamic>> rows) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.parse(v.toString());
    }

    int _toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.parse(v.toString());
    }

    final products = rows.map((r) {
      return Product(
        id: const Uuid().v4(),
        name: (r['name'] as String).trim(),
        sku: (r['sku'] as String?)?.trim().isEmpty == true
            ? null
            : (r['sku'] as String?)?.trim(),
        category: (r['category'] as String?)?.trim().isEmpty == true
            ? null
            : (r['category'] as String?)?.trim(),
        price: _toDouble(r['price']),
        cost: r['cost'] == null ? null : _toDouble(r['cost']),
        stock: _toInt(r['stock']),
        createdAt: now,
        updatedAt: now,
      );
    }).toList();

    await _dao.insertBulk(products);
  }


  Future<void> update(Product p) => _dao.update(p);

  Future<void> delete(String id) => _dao.delete(id);
}
