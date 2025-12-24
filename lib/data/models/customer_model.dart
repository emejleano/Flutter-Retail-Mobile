class Customer {
  final String customerId;
  final String customerName;
  final String segment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.customerId,
    required this.customerName,
    required this.segment,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    DateTime? toDateTimeOrNull(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return Customer(
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      segment: json['segment'] ?? '',
      createdAt: toDateTimeOrNull(json['created_at']),
      updatedAt: toDateTimeOrNull(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'segment': segment,
    };
  }

  Customer copyWith({
    String? customerId,
    String? customerName,
    String? segment,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      segment: segment ?? this.segment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
