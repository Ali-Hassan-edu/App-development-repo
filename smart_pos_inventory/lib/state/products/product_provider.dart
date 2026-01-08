// lib/state/products/product_provider.dart
import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  ProductProvider(this._repo);

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
      items = await _repo.getAll();
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
      await _repo.add(
        name: name,
        sku: sku,
        category: category,
        price: price,
        cost: cost,
        stock: stock,
      );
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

  /// ✅ BULK ADD
  /// rows payload example:
  /// [{'name':'Tea','sku':null,'category':'Drinks','price':50.0,'cost':30.0,'stock':10}, ...]
  Future<String?> addProductsBulk(List<Map<String, dynamic>> rows) async {
    try {
      // ✅ validation before repo call (so user gets snackBar-friendly errors)
      for (int i = 0; i < rows.length; i++) {
        final r = rows[i];

        final name = (r['name'] ?? '').toString().trim();
        final price = _toDouble(r['price']);
        final stock = _toInt(r['stock'], fallback: 0);

        if (name.isEmpty) return 'Row ${i + 1}: Product name is required';
        if (price == null || price <= 0) return 'Row ${i + 1}: Price must be greater than 0';
        if (stock < 0) return 'Row ${i + 1}: Stock cannot be negative';
      }

      await _repo.addBulk(rows);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProduct(Product p) async {
    try {
      await _repo.update(p);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteProduct(String id) async {
    try {
      await _repo.delete(id);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
