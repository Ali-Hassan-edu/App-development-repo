class Product {
  final String id;
  final String name;
  final String? sku;
  final String? category;
  final double price;
  final double? cost;
  final int stock;
  final int createdAt;
  final int updatedAt;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    required this.price,
    this.cost,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? name,
    String? sku,
    String? category,
    double? price,
    double? cost,
    int? stock,
    int? updatedAt,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ MAP (used by sqlite / firestore)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sku': sku,
    'category': category,
    'price': price,
    'cost': cost,
    'stock': stock,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: (map['id'] ?? '').toString(),
    name: (map['name'] ?? '').toString(),
    sku: map['sku'] as String?,
    category: map['category'] as String?,
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    cost: map['cost'] == null ? null : (map['cost'] as num).toDouble(),
    stock: (map['stock'] as num?)?.toInt() ?? 0,
    createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
    updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
  );

  // ✅ JSON aliases (so code using fromJson/toJson also works)
  Map<String, dynamic> toJson() => toMap();
  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);
}
