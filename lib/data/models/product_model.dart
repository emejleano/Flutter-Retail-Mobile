class Product {
  final String productId;
  final String category;
  final String subCategory;
  final String productName;
  final double? avgUnitPrice;
  final int stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.productId,
    required this.category,
    required this.subCategory,
    required this.productName,
    this.avgUnitPrice,
    this.stock = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double? toDoubleOrNull(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime? toDateTimeOrNull(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    int toIntOrZero(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Product(
      productId: json['product_id'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      productName: json['product_name'] ?? '',
      avgUnitPrice: toDoubleOrNull(json['avg_unit_price']),
      stock: toIntOrZero(json['stock']),
      createdAt: toDateTimeOrNull(json['created_at']),
      updatedAt: toDateTimeOrNull(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'category': category,
      'sub_category': subCategory,
      'product_name': productName,
      if (avgUnitPrice != null) 'avg_unit_price': avgUnitPrice,
      'stock': stock,
    };
  }

  Product copyWith({
    String? productId,
    String? category,
    String? subCategory,
    String? productName,
    double? avgUnitPrice,
    int? stock,
  }) {
    return Product(
      productId: productId ?? this.productId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      productName: productName ?? this.productName,
      avgUnitPrice: avgUnitPrice ?? this.avgUnitPrice,
      stock: stock ?? this.stock,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
