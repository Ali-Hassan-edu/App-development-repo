import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  ProductProvider(this._repo);

  bool loading = false;
  String? error;
  List<Product> items = [];

  /// ✅ Dynamic Dashboard Stats
  int get totalItems => items.length;

  int get lowStockCount {
    const threshold = 5; // change if you want
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
