import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_models.dart';

class CustomerStore {
  static const _key = 'pos_customers_v1';

  static Future<List<Customer>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    final list = (jsonDecode(raw) as List)
        .map((e) => Customer.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> saveAll(List<Customer> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
