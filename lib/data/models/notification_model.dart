class StockAlert {
  final String productId;
  final String productName;
  final String category;
  final int currentStock;
  final int minimumStock;
  final AlertType alertType;
  final DateTime createdAt;

  StockAlert({
    required this.productId,
    required this.productName,
    required this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.alertType,
    required this.createdAt,
  });

  bool get isLowStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock == 0;

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    AlertType parseAlertType(dynamic value) {
      final v = (value ?? '').toString();
      return AlertType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => AlertType.lowStock,
      );
    }

    DateTime parseDate(dynamic value) {
      final v = (value ?? '').toString();
      return DateTime.tryParse(v) ?? DateTime.now();
    }

    int parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return StockAlert(
      productId: (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      currentStock: parseInt(json['current_stock']),
      minimumStock: parseInt(json['minimum_stock']),
      alertType: parseAlertType(json['alert_type']),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'alert_type': alertType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum AlertType {
  lowStock,
  outOfStock,
  stockOpname,
  priceChange,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(dynamic value) {
      final v = (value ?? '').toString();
      return NotificationType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => NotificationType.systemMessage,
      );
    }

    DateTime parseDate(dynamic value) {
      final v = (value ?? '').toString();
      return DateTime.tryParse(v) ?? DateTime.now();
    }

    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: parseType(json['type']),
      createdAt: parseDate(json['created_at']),
      isRead: json['is_read'] == true,
      data: json['data'] is Map<String, dynamic>
          ? (json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      if (data != null) 'data': data,
    };
  }
}

enum NotificationType {
  // Admin/Owner notifications
  stockAlert,      // Low stock warning
  stockOpname,     // Stock opname reminder
  salesUpdate,     // Sales performance update
  dataModified,    // Admin CRUD operations (create/update/delete data)
  
  // Customer notifications
  orderPlaced,     // Order placed successfully
  orderShipped,    // Order shipped
  orderDelivered,  // Order delivered
  promotion,       // Promotional offers
  
  // System (both roles)
  systemMessage,
  reminder,
}

extension NotificationTypeExtension on NotificationType {
  bool get isAdminNotification {
    return this == NotificationType.stockAlert ||
           this == NotificationType.stockOpname ||
           this == NotificationType.salesUpdate ||
           this == NotificationType.dataModified;
  }
  
  bool get isCustomerNotification {
    return this == NotificationType.orderPlaced ||
           this == NotificationType.orderShipped ||
           this == NotificationType.orderDelivered ||
           this == NotificationType.promotion;
  }
  
  bool get isSystemNotification {
    return this == NotificationType.systemMessage ||
           this == NotificationType.reminder;
  }
}
