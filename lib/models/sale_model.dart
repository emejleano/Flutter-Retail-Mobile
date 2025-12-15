class Sale {
  final String customerId;
  final String productId;
  final int quantity;
  final String date; // ISO date string, e.g. 2025-12-14

  Sale({
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.date,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    int parseQuantity(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Sale(
      customerId: json['customer_id'] ?? '',
      productId: json['product_id'] ?? '',
      quantity: parseQuantity(json['quantity']),
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'product_id': productId,
        'quantity': quantity,
        'date': date,
      };
}
