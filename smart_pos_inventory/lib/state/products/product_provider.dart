import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/product.dart';
import '../../core/firestore_paths.dart';

class ProductProvider extends ChangeNotifier {
  bool loading = false;
  String? error;
  List<Product> items = [];

  int get totalItems => items.length;

  int get lowStockCount {
    const threshold = 5;
    return items.where((p) => p.stock <= threshold).length;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final snap = await FirePaths.products()
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      items = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        return Product.fromMap({...data, 'id': d.id});
      }).toList();
    } catch (e) {
      error = e.toString();
      items = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<String?> addProduct({
    required String name,
    String? sku,
    String? category,
    required double price,
    double? cost,
    int stock = 0,
  }) async {
    try {
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

      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ---------- BULK ADD helpers ----------
  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim()) ?? fallback;
  }
  // -------------------------------------

  Future<String?> addProductsBulk(List<Map<String, dynamic>> rows) async {
    try {
      for (int i = 0; i < rows.length; i++) {
        final r = rows[i];
        final name = (r['name'] ?? '').toString().trim();
        final price = _toDouble(r['price']);
        final stock = _toInt(r['stock'], fallback: 0);

        if (name.isEmpty) return 'Row ${i + 1}: Product name is required';
        if (price == null || price <= 0) return 'Row ${i + 1}: Price must be greater than 0';
        if (stock < 0) return 'Row ${i + 1}: Stock cannot be negative';
      }

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
          'price': (_toDouble(r['price']) ?? 0).toDouble(),
          'cost': r['cost'] == null ? null : _toDouble(r['cost']),
          'stock': _toInt(r['stock'], fallback: 0),
          'createdAt': now,
          'updatedAt': now,
        });
      }

      await batch.commit();
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProduct(Product p) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await FirePaths.products().doc(p.id).update({
        ...p.toMap(),
        'updatedAt': now,
      });
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteProduct(String id) async {
    try {
      await FirePaths.products().doc(id).delete();
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
