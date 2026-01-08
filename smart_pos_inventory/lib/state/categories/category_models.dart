class Category {
  final String id;
  final String name;
  final int createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    int? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt,
  };

  static Category fromMap(Map<String, dynamic> m) {
    return Category(
      id: m['id'] as String,
      name: (m['name'] ?? '') as String,
      createdAt: (m['createdAt'] as num).toInt(),
    );
  }
}
