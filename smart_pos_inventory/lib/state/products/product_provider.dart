import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  ProductProvider(this._repo);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<Product> _items = [];
  List<Product> get items => _items;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repo.getAll();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
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
      _items.removeWhere((x) => x.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
