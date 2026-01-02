// lib/state/reports/report_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'report_models.dart';

class ReportStore {
  static const _salesKey = 'pos_sales_history_v1';
  static const _purchaseKey = 'pos_purchase_history_v1';

  // ---------------- SALES ----------------
  static Future<List<SaleRecord>> getSales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_salesKey);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final list = decoded
        .map((e) => SaleRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> addSale(SaleRecord s) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getSales();
    final updated = [s, ...current];
    final raw = jsonEncode(updated.map((e) => e.toJson()).toList());
    await prefs.setString(_salesKey, raw);
  }

  static Future<void> clearSales() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_salesKey);
  }

  // ---------------- PURCHASES ----------------
  static Future<List<PurchaseRecord>> getPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_purchaseKey);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final list = decoded
        .map((e) => PurchaseRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> addPurchase(PurchaseRecord p) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getPurchases();
    final updated = [p, ...current];
    final raw = jsonEncode(updated.map((e) => e.toJson()).toList());
    await prefs.setString(_purchaseKey, raw);
  }

  static Future<void> clearPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_purchaseKey);
  }
}
