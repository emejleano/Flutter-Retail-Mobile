import 'product_model.dart';
import 'customer_model.dart';
import 'region_model.dart';

class Sale {
  final int? factId;
  final String orderId;
  final int dateId;
  final int? shipDateId;
  final String customerId;
  final String productId;
  final String regionId;
  final double sales;
  final int quantity;
  final double discount;
  final double profit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Related models
  final Product? product;
  final Customer? customer;
  final Region? region;
  final OrderDate? orderDate;

  Sale({
    this.factId,
    required this.orderId,
    required this.dateId,
    this.shipDateId,
    required this.customerId,
    required this.productId,
    required this.regionId,
    required this.sales,
    required this.quantity,
    this.discount = 0,
    required this.profit,
    this.createdAt,
    this.updatedAt,
    this.product,
    this.customer,
    this.region,
    this.orderDate,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    int toInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    int? toIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    DateTime? toDateTimeOrNull(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    Map<String, dynamic>? asStringKeyedMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      return null;
    }

    return Sale(
      factId: toIntOrNull(json['fact_id']),
      orderId: json['order_id']?.toString() ?? '',
      dateId: toInt(json['date_id']),
      shipDateId: toIntOrNull(json['ship_date_id']),
      customerId: json['customer_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      regionId: json['region_id']?.toString() ?? '',
      sales: toDouble(json['sales']),
      quantity: toInt(json['quantity'], fallback: 1),
      discount: toDouble(json['discount']),
      profit: toDouble(json['profit']),
      createdAt: toDateTimeOrNull(json['created_at']),
      updatedAt: toDateTimeOrNull(json['updated_at']),
      product: asStringKeyedMap(json['product']) != null
          ? Product.fromJson(asStringKeyedMap(json['product'])!)
          : null,
      customer: asStringKeyedMap(json['customer']) != null
          ? Customer.fromJson(asStringKeyedMap(json['customer'])!)
          : null,
      region: asStringKeyedMap(json['region']) != null
          ? Region.fromJson(asStringKeyedMap(json['region'])!)
          : null,
      orderDate: asStringKeyedMap(json['order_date']) != null
          ? OrderDate.fromJson(asStringKeyedMap(json['order_date'])!)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'date_id': dateId,
      'ship_date_id': shipDateId,
      'customer_id': customerId,
      'product_id': productId,
      'region_id': regionId,
      'sales': sales,
      'quantity': quantity,
      'discount': discount,
      'profit': profit,
    };
  }

  Sale copyWith({
    int? factId,
    String? orderId,
    int? dateId,
    int? shipDateId,
    String? customerId,
    String? productId,
    String? regionId,
    double? sales,
    int? quantity,
    double? discount,
    double? profit,
  }) {
    return Sale(
      factId: factId ?? this.factId,
      orderId: orderId ?? this.orderId,
      dateId: dateId ?? this.dateId,
      shipDateId: shipDateId ?? this.shipDateId,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      regionId: regionId ?? this.regionId,
      sales: sales ?? this.sales,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      profit: profit ?? this.profit,
      createdAt: createdAt,
      updatedAt: updatedAt,
      product: product,
      customer: customer,
      region: region,
      orderDate: orderDate,
    );
  }
}

class OrderDate {
  final int dateId;
  final String fullDate;
  final int year;
  final int month;
  final String monthName;

  OrderDate({
    required this.dateId,
    required this.fullDate,
    required this.year,
    required this.month,
    required this.monthName,
  });

  factory OrderDate.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return OrderDate(
      dateId: toInt(json['date_id']),
      fullDate: json['full_date']?.toString() ?? '',
      year: toInt(json['year']),
      month: toInt(json['month']),
      monthName: json['month_name']?.toString() ?? '',
    );
  }
}
