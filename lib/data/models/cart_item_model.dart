import 'product_model.dart';

/// Local cart item (used when offline or for UI state)
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Customer price (5% markup over base price)
  double get customerPrice => (product.avgUnitPrice ?? 0) * 1.05;
  
  /// Subtotal with customer markup
  double get subtotal => customerPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.productId,
      'product_name': product.productName,
      'category': product.category,
      'unit_price': product.avgUnitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

/// Backend cart item (from /api/cart response)
class BackendCartItem {
  final int id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final Product? product;

  BackendCartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.product,
  });

  /// Customer price (5% markup over base price)
  double get customerPrice => unitPrice * 1.05;
  
  /// Customer subtotal with markup
  double get customerSubtotal => customerPrice * quantity;

  factory BackendCartItem.fromJson(Map<String, dynamic> json) {
    return BackendCartItem(
      id: _parseInt(json['id']),
      productId: (json['product_id'] ?? '').toString(),
      quantity: _parseInt(json['quantity'], fallback: 1),
      unitPrice: _parseDouble(json['unit_price']),
      subtotal: _parseDouble(json['subtotal']),
      product: json['product'] != null 
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}

/// Backend cart response
class BackendCart {
  final List<BackendCartItem> items;
  final double total;

  BackendCart({
    required this.items,
    required this.total,
  });

  factory BackendCart.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return BackendCart(
      items: itemsList
          .map((e) => BackendCartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: BackendCartItem._parseDouble(json['total']),
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}
