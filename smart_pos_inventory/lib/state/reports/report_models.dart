// lib/state/reports/report_models.dart
import 'dart:convert';

/// ---------------- SALE RECORD ----------------
class SaleRecord {
  final String id;
  final int createdAt;
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  final double subTotal;
  final double discount;
  final double tax;
  final double grandTotal;
  final List<SaleLineItem> items;

  const SaleRecord({
    required this.id,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethod,
    required this.subTotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.items,
  });

  factory SaleRecord.fromJson(Map<String, dynamic> json) {
    return SaleRecord(
      id: (json['id'] ?? '').toString(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      customerName: (json['customerName'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      paymentMethod: (json['paymentMethod'] ?? '').toString(),
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      items: ((json['items'] as List?) ?? [])
          .map((e) => SaleLineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'paymentMethod': paymentMethod,
    'subTotal': subTotal,
    'discount': discount,
    'tax': tax,
    'grandTotal': grandTotal,
    'items': items.map((e) => e.toJson()).toList(),
  };

  // Storage helpers (SharedPreferences)
  static List<SaleRecord> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map((e) => SaleRecord.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static String encodeList(List<SaleRecord> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }
}

class SaleLineItem {
  final String productId;
  final String name;
  final int qty;
  final double unitPrice;

  const SaleLineItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  double get total => qty * unitPrice;

  factory SaleLineItem.fromJson(Map<String, dynamic> json) {
    return SaleLineItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'qty': qty,
    'unitPrice': unitPrice,
  };
}

/// ---------------- PURCHASE RECORD (✅ REQUIRED BY report_store.dart) ----------------
/// This is for "Purchase Report" / stock purchases (inventory in).
class PurchaseRecord {
  final String id;
  final int createdAt;

  /// Optional supplier info
  final String supplierName;
  final String supplierPhone;

  final double subTotal;
  final double tax;
  final double grandTotal;

  final List<PurchaseLineItem> items;

  const PurchaseRecord({
    required this.id,
    required this.createdAt,
    required this.supplierName,
    required this.supplierPhone,
    required this.subTotal,
    required this.tax,
    required this.grandTotal,
    required this.items,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: (json['id'] ?? '').toString(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      supplierName: (json['supplierName'] ?? '').toString(),
      supplierPhone: (json['supplierPhone'] ?? '').toString(),
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      items: ((json['items'] as List?) ?? [])
          .map((e) => PurchaseLineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'supplierName': supplierName,
    'supplierPhone': supplierPhone,
    'subTotal': subTotal,
    'tax': tax,
    'grandTotal': grandTotal,
    'items': items.map((e) => e.toJson()).toList(),
  };

  static List<PurchaseRecord> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map((e) => PurchaseRecord.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static String encodeList(List<PurchaseRecord> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }
}

class PurchaseLineItem {
  final String productId;
  final String name;
  final int qty;
  final double unitCost;

  const PurchaseLineItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitCost,
  });

  double get total => qty * unitCost;

  factory PurchaseLineItem.fromJson(Map<String, dynamic> json) {
    return PurchaseLineItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'qty': qty,
    'unitCost': unitCost,
  };
}

/// ---------------- DAY POINT (CHART) ----------------
class DayPoint {
  final String label;
  final double total;
  const DayPoint({required this.label, required this.total});
}
