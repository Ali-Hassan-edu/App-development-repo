import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/firestore_paths.dart';
import '../models/product.dart';

class ProductRepositoryFs {
  /// Get all products (latest first)
  Future<List<Product>> getAll() async {
    final snap = await FirePaths.products()
        .orderBy('createdAt', descending: true)
        .limit(500)
        .get();

    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      return Product.fromMap({...data, 'id': d.id});
    }).toList();
  }

  /// Add single product
  Future<void> add({
    required String name,
    String? sku,
    String? category,
    required double price,
    double? cost,
    int stock = 0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final doc = FirePaths.products().doc();

    await doc.set({
      'id': doc.id,
      'name': name.trim(),
      'sku': (sku == null || sku.trim().isEmpty) ? null : sku.trim(),
      'category': (category == null || category.trim().isEmpty) ? null : category.trim(),
      'price': price,
      'cost': cost,
      'stock': stock,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  /// Update product
  Future<void> update(Product p) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await FirePaths.products().doc(p.id).update({
      ...p.toMap(),
      'updatedAt': now,
    });
  }

  /// Delete product
  Future<void> delete(String id) async {
    await FirePaths.products().doc(id).delete();
  }

  /// Bulk add (CSV / bulk screen)
  Future<void> addBulk(List<Map<String, dynamic>> rows) async {
    final batch = FirebaseFirestore.instance.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final r in rows) {
      final doc = FirePaths.products().doc();

      batch.set(doc, {
        'id': doc.id,
        'name': (r['name'] ?? '').toString().trim(),
        'sku': (r['sku'] == null || r['sku'].toString().trim().isEmpty)
            ? null
            : r['sku'].toString().trim(),
        'category': (r['category'] == null || r['category'].toString().trim().isEmpty)
            ? null
            : r['category'].toString().trim(),
        'price': (r['price'] as num).toDouble(),
        'cost': r['cost'] == null ? null : (r['cost'] as num).toDouble(),
        'stock': (r['stock'] as num?)?.toInt() ?? 0,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    await batch.commit();
  }
}
