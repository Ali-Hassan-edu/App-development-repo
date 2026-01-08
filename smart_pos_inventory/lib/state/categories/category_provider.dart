import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'category_models.dart';
import 'category_store.dart';

class CategoryProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<Category> categories = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      categories = await CategoryStore.getAll();
    } catch (e) {
      error = e.toString();
      categories = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await CategoryStore.saveAll(categories);
  }

  List<Category> search(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return categories;
    return categories.where((c) => c.name.toLowerCase().contains(s)).toList();
  }

  Future<String?> addCategory(String name) async {
    final n = name.trim();
    if (n.isEmpty) return 'Category name is required';

    final exists = categories.any((c) => c.name.toLowerCase() == n.toLowerCase());
    if (exists) return 'Category already exists';

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final item = Category(
        id: const Uuid().v4(),
        name: n,
        createdAt: now,
      );

      categories.insert(0, item);
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateCategory(Category c) async {
    final n = c.name.trim();
    if (n.isEmpty) return 'Category name is required';

    final dup = categories.any((x) => x.id != c.id && x.name.toLowerCase() == n.toLowerCase());
    if (dup) return 'Category already exists';

    try {
      final idx = categories.indexWhere((x) => x.id == c.id);
      if (idx == -1) return 'Category not found';

      categories[idx] = c.copyWith(name: n);
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteCategory(String id) async {
    try {
      categories.removeWhere((x) => x.id == id);
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
