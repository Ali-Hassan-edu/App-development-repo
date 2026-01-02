// lib/state/reports/report_provider.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'report_models.dart';

class ReportProvider extends ChangeNotifier {
  static const _key = 'sales_records_v1';

  bool loading = false;
  String? error;

  List<SaleRecord> sales = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);

      if (raw != null && raw.trim().isNotEmpty) {
        sales = SaleRecord.decodeList(raw);
      } else {
        sales = [];
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, SaleRecord.encodeList(sales));
  }

  Future<void> addSale(SaleRecord record) async {
    sales.insert(0, record);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    sales = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }

  // ---------- KPIs ----------
  double get todayTotal {
    final now = DateTime.now();
    return sales.where((s) {
      final d = DateTime.fromMillisecondsSinceEpoch(s.createdAt);
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (a, b) => a + b.grandTotal);
  }

  double get monthTotal {
    final now = DateTime.now();
    return sales.where((s) {
      final d = DateTime.fromMillisecondsSinceEpoch(s.createdAt);
      return d.year == now.year && d.month == now.month;
    }).fold(0.0, (a, b) => a + b.grandTotal);
  }

  int get monthTransactions {
    final now = DateTime.now();
    return sales.where((s) {
      final d = DateTime.fromMillisecondsSinceEpoch(s.createdAt);
      return d.year == now.year && d.month == now.month;
    }).length;
  }

  double get monthAvgTicket {
    final tx = monthTransactions;
    if (tx == 0) return 0.0;
    return monthTotal / tx;
  }

  // ---------- Chart: last N days totals ----------
  /// Returns list of (label, total) for last [days] days including today.
  List<DayPoint> lastDays(int days) {
    final now = DateTime.now();
    final start =
    DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    final map = <String, double>{};
    for (int i = 0; i < days; i++) {
      final d = start.add(Duration(days: i));
      map[_dayKey(d)] = 0.0;
    }

    for (final s in sales) {
      final d = DateTime.fromMillisecondsSinceEpoch(s.createdAt);
      final day = DateTime(d.year, d.month, d.day);
      if (day.isBefore(start)) continue;

      final key = _dayKey(day);
      if (map.containsKey(key)) {
        map[key] = (map[key] ?? 0.0) + s.grandTotal;
      }
    }

    return map.entries.map((e) {
      final parts = e.key.split('-'); // yyyy-mm-dd
      final mm = parts[1];
      final dd = parts[2];
      return DayPoint(label: '$dd/$mm', total: e.value);
    }).toList();
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------- Item Sales Aggregation ----------
  List<ItemAgg> topItems({int limit = 10}) {
    final map = <String, ItemAgg>{};

    for (final s in sales) {
      for (final i in s.items) {
        final key = i.productId.isNotEmpty ? i.productId : i.name;

        final current = map[key] ??
            ItemAgg(
              key: key,
              name: i.name,
              qty: 0,
              revenue: 0.0,
            );

        map[key] = current.copyWith(
          qty: current.qty + i.qty,
          revenue: current.revenue + i.total,
        );
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => b.revenue.compareTo(a.revenue));
    return list.take(limit).toList();
  }

  // ---------- Demo Data ----------
  Future<void> generateDemo({int days = 12}) async {
    final rnd = Random();
    final now = DateTime.now();
    final uuid = const Uuid();

    final demo = <SaleRecord>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final txCount = 1 + rnd.nextInt(4);

      for (int t = 0; t < txCount; t++) {
        final createdAt = date.add(
          Duration(hours: 9 + rnd.nextInt(9), minutes: rnd.nextInt(60)),
        );

        final items = <SaleLineItem>[];
        final itemCount = 1 + rnd.nextInt(4);

        for (int k = 0; k < itemCount; k++) {
          final qty = 1 + rnd.nextInt(3);
          final price = (50 + rnd.nextInt(400)).toDouble();

          items.add(SaleLineItem(
            productId: 'p${1 + rnd.nextInt(6)}',
            name: ['Tea', 'Coffee', 'Biscuit', 'Chips', 'Milk', 'Bread']
            [rnd.nextInt(6)],
            qty: qty,
            unitPrice: price,
          ));
        }

        final subTotal = items.fold(0.0, (a, b) => a + b.total);
        final discount = rnd.nextBool() ? min(30.0, subTotal * 0.05) : 0.0;
        final tax = (subTotal - discount) * 0.02;
        final grand = (subTotal - discount) + tax;

        demo.add(SaleRecord(
          id: uuid.v4().substring(0, 8).toUpperCase(),
          createdAt: createdAt.millisecondsSinceEpoch,
          customerName:
          rnd.nextBool() ? 'Walk-in' : 'Customer ${1 + rnd.nextInt(30)}',
          customerPhone: '',
          paymentMethod: ['Cash', 'UPI', 'Card'][rnd.nextInt(3)],
          subTotal: subTotal,
          discount: discount,
          tax: tax,
          grandTotal: grand,
          items: items,
        ));
      }
    }

    sales = [...demo, ...sales];
    await _save();
    notifyListeners();
  }
}

class ItemAgg {
  final String key;
  final String name;
  final int qty;
  final double revenue;

  const ItemAgg({
    required this.key,
    required this.name,
    required this.qty,
    required this.revenue,
  });

  ItemAgg copyWith({String? name, int? qty, double? revenue}) => ItemAgg(
    key: key,
    name: name ?? this.name,
    qty: qty ?? this.qty,
    revenue: revenue ?? this.revenue,
  );
}
