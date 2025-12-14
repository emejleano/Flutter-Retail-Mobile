class Product {
  final dynamic id;
  final String productName;
  final String category;
  final String subCategory;
  final double price;

  Product({
    required this.id,
    required this.productName,
    required this.category,
    required this.subCategory,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic p) {
      if (p == null) return 0.0;
      if (p is double) return p;
      if (p is int) return p.toDouble();
      if (p is String) {
        final cleaned = p.replaceAll(',', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    // product id may be under 'id' or 'product_id'
    final idVal = json['id'] ?? json['product_id'];

    // price may be returned under several keys (sales, price, list_price, unit_price)
    final priceVal = json['price'] ?? json['sales'] ?? json['sale'] ?? json['list_price'] ?? json['unit_price'];

    return Product(
      id: idVal,
      productName: (json['product_name'] ?? json['name'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
      subCategory: (json['sub_category'] ?? '').toString().trim(),
      price: parsePrice(priceVal),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_name': productName,
        'category': category,
        'sub_category': subCategory,
        'price': price,
      };
}
