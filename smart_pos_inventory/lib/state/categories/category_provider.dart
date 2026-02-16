import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/firestore_paths.dart';
import 'category_models.dart';

class CategoryProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<Category> categories = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final snap = await FirePaths.categories()
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      categories = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        return Category.fromMap({...data, 'id': d.id});
      }).toList();
    } catch (e) {
      error = e.toString();
      categories = [];
    }

    loading = false;
    notifyListeners();
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
      final id = const Uuid().v4();
      final item = Category(id: id, name: n, createdAt: now);

      await FirePaths.categories().doc(id).set(item.toMap());
      await load();
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
      await FirePaths.categories().doc(c.id).update({
        ...c.toMap(),
        'name': n,
      });
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteCategory(String id) async {
    try {
      await FirePaths.categories().doc(id).delete();
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
