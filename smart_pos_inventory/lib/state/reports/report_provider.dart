import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/firestore_paths.dart';
import '../pos/cart_provider.dart';
import 'report_models.dart';

class ReportProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<SaleRecord> sales = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final snap = await FirePaths.sales()
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      sales = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        return SaleRecord.fromJson({
          ...data,
          'id': data['id'] ?? d.id,
        });
      }).toList();
    } catch (e) {
      error = e.toString();
      sales = [];
    }

    loading = false;
    notifyListeners();
  }



  Future<void> addSale(SaleRecord record) async {
    // record.id will be used as Firestore docId
    await FirePaths.sales().doc(record.id).set(record.toJson());
    sales.insert(0, record);
    notifyListeners();
  }

  /// ✅ Save sale directly from CartProvider (used by CheckoutScreen)
  Future<void> addSaleFromCart({
    required String invoiceId,
    required CartProvider cart,
    required int createdAt,
    String paymentMethod = 'Cash',
  }) async {
    if (cart.items.isEmpty) return;

    final items = cart.items
        .map((l) => SaleLineItem(
      productId: l.product.id,
      name: l.product.name,
      qty: l.qty,
      unitPrice: l.unitPrice,
    ))
        .toList();

    final record = SaleRecord(
      id: invoiceId,
      createdAt: createdAt,
      customerName: cart.customerName.trim().isEmpty ? 'Walk-in' : cart.customerName.trim(),
      customerPhone: cart.fullPhone,
      paymentMethod: paymentMethod,
      subTotal: cart.subTotal,
      discount: cart.discountAmount,
      tax: cart.taxAmount,
      grandTotal: cart.grandTotal,
      items: items,
    );

    await FirePaths.sales().doc(record.id).set(record.toJson());
    sales.insert(0, record);
    notifyListeners();
  }

  Future<void> clearAll() async {
    // Firestore delete all requires batch; we’ll do safe chunk delete
    final col = FirePaths.sales();
    final snap = await col.limit(500).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    sales = [];
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
  List<DayPoint> lastDays(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

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
      final parts = e.key.split('-');
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
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
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
            name: ['Tea', 'Coffee', 'Biscuit', 'Chips', 'Milk', 'Bread'][rnd.nextInt(6)],
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
          customerName: rnd.nextBool() ? 'Walk-in' : 'Customer ${1 + rnd.nextInt(30)}',
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

    // save demo to firestore (batch)
    final batch = FirebaseFirestore.instance.batch();
    final col = FirePaths.sales();
    for (final r in demo) {
      batch.set(col.doc(r.id), r.toJson());
    }
    await batch.commit();

    await load();
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
