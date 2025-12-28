class InventoryLog {
  final String id;
  final String productId;
  final String type; // IN / OUT / ADJUST
  final int qty;
  final String? note;
  final int createdAt;

  InventoryLog({
    required this.id,
    required this.productId,
    required this.type,
    required this.qty,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'type': type,
    'qty': qty,
    'note': note,
    'createdAt': createdAt,
  };

  factory InventoryLog.fromMap(Map<String, dynamic> map) => InventoryLog(
    id: map['id'] as String,
    productId: map['productId'] as String,
    type: map['type'] as String,
    qty: (map['qty'] as num).toInt(),
    note: map['note'] as String?,
    createdAt: (map['createdAt'] as num).toInt(),
  );
}
