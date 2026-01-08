import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_models.dart';

class CategoryStore {
  static const _key = 'categories_v1';

  static Future<List<Category>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveAll(List<Category> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => e.toMap()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }
}
