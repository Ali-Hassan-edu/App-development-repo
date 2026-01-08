class LedgerEntry {
  final String id;
  final String customerId;

  /// "debit" | "credit" | "payment"
  final String type;

  final double amount;
  final String? note;

  /// epoch millis
  final int createdAt;

  /// 0 = not synced, 1 = synced (for future online sync)
  final int synced;

  const LedgerEntry({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
    this.synced = 0,
  });

  LedgerEntry copyWith({
    String? id,
    String? customerId,
    String? type,
    double? amount,
    String? note,
    int? createdAt,
    int? synced,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type,
      'amount': amount,
      'note': note,
      'createdAt': createdAt,
      'synced': synced,
    };
  }

  static LedgerEntry fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: (map['createdAt'] as num).toInt(),
      synced: (map['synced'] as num?)?.toInt() ?? 0,
    );
  }

  static bool isValidType(String t) =>
      t == 'debit' || t == 'credit' || t == 'payment';
}
