class Category {
  final String id;
  final String color;
  final String name;
  final String adminId;
  final int v;

  Category({
    required this.id,
    required this.color,
    required this.name,
    required this.adminId,
    required this.v,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      color: json['color'] as String,
      name: json['name'] as String,
      adminId: json['adminId'] as String,
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'color': color,
      'name': name,
      'adminId': adminId,
      '__v': v,
    };
  }

  Category copyWith({
    String? id,
    String? color,
    String? name,
    String? adminId,
    int? v,
  }) {
    return Category(
      id: id ?? this.id,
      color: color ?? this.color,
      name: name ?? this.name,
      adminId: adminId ?? this.adminId,
      v: v ?? this.v,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, color: $color, name: $name, adminId: $adminId, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}