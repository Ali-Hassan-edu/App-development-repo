class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final int createdAt;
  final int updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    int? createdAt,
    int? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: (map['id'] ?? '').toString(),
    name: (map['name'] ?? '').toString(),
    phone: (map['phone'] ?? '').toString(),
    address: map['address'] as String?,
    createdAt: (map['createdAt'] as num? ?? 0).toInt(),
    updatedAt: (map['updatedAt'] as num? ?? 0).toInt(),
  );
}
