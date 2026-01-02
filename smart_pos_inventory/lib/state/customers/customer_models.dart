// lib/state/customers/customer_models.dart
import 'dart:convert';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final int createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    int? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'createdAt': createdAt,
  };

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: json['address'] == null ? null : json['address'].toString(),
      createdAt: (json['createdAt'] is int)
          ? json['createdAt'] as int
          : int.tryParse((json['createdAt'] ?? '0').toString()) ?? 0,
    );
  }

  static String encodeList(List<Customer> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Customer> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .map((e) => Customer.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
