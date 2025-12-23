import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  static const _prefsKeyNotifications = 'notifications.v1';
  static const _prefsKeyStockAlerts = 'stock_alerts.v1';

  final List<AppNotification> _notifications = [];
  final List<StockAlert> _stockAlerts = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;  // Track user role
  
  List<AppNotification> get notifications => _notifications;
  List<StockAlert> get stockAlerts => _stockAlerts;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  
  // Filtered notifications by role
  List<AppNotification> get adminNotifications => _notifications
      .where((n) => n.type.isAdminNotification || n.type.isSystemNotification)
      .toList();
      
  List<AppNotification> get customerNotifications => _notifications
      .where((n) => n.type.isCustomerNotification || n.type.isSystemNotification)
      .toList();
      
  List<AppNotification> get filteredNotifications => 
      _isAdmin ? adminNotifications : customerNotifications;
  
  int get filteredUnreadCount => filteredNotifications.where((n) => !n.isRead).length;
  bool get hasFilteredUnread => filteredUnreadCount > 0;
  
  NotificationProvider() {
    // Restore persisted notifications (real, not hardcoded)
    Future.microtask(() => loadNotifications());
  }
  
  /// Set user role to filter notifications accordingly
  void setUserRole({required bool isAdmin}) {
    _isAdmin = isAdmin;
    _updateUnreadCount();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final rawNotifications = prefs.getString(_prefsKeyNotifications);
      final rawAlerts = prefs.getString(_prefsKeyStockAlerts);

      _notifications
        ..clear()
        ..addAll(_decodeNotifications(rawNotifications));

      _stockAlerts
        ..clear()
        ..addAll(_decodeStockAlerts(rawAlerts));

      _updateUnreadCount(shouldNotify: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AppNotification> _decodeNotifications(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  List<StockAlert> _decodeStockAlerts(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(StockAlert.fromJson)
        .toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKeyNotifications,
      jsonEncode(_notifications.map((n) => n.toJson()).toList()),
    );
    await prefs.setString(
      _prefsKeyStockAlerts,
      jsonEncode(_stockAlerts.map((a) => a.toJson()).toList()),
    );
  }

  void _updateUnreadCount({bool shouldNotify = true}) {
    _unreadCount = filteredNotifications.where((n) => !n.isRead).length;
    if (shouldNotify) notifyListeners();
  }
  
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    _persist();
  }
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      _persist();
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
    _persist();
  }
  
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    _persist();
  }
  
  void clearAll() {
    _notifications.clear();
    _updateUnreadCount();
    _persist();
  }
  
  // ==================== ADMIN NOTIFICATIONS ====================
  
  void addStockOpnameReminder() {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Stock Opname',
        message: 'Time for stock opname check!',
        type: NotificationType.stockOpname,
        createdAt: DateTime.now(),
      ),
    );
  }
  
  void addLowStockAlert(String productName, {int? currentStock, int? minStock}) {
    final stockInfo = currentStock != null && minStock != null 
        ? ' (Stock: $currentStock, Min: $minStock)' 
        : '';
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Low Stock Alert',
        message: 'Product "$productName" is running low on stock$stockInfo',
        type: NotificationType.stockAlert,
        createdAt: DateTime.now(),
      ),
    );
  }
  
  // ==================== CUSTOMER NOTIFICATIONS ====================
  
  void addOrderPlacedNotification(String orderId, double total) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Order Placed',
        message: 'Your order #$orderId has been placed successfully. Total: \$${total.toStringAsFixed(2)}',
        type: NotificationType.orderPlaced,
        createdAt: DateTime.now(),
        data: {'order_id': orderId, 'total': total},
      ),
    );
  }
  
  void addOrderShippedNotification(String orderId) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Order Shipped',
        message: 'Your order #$orderId has been shipped!',
        type: NotificationType.orderShipped,
        createdAt: DateTime.now(),
        data: {'order_id': orderId},
      ),
    );
  }
  
  void addOrderDeliveredNotification(String orderId) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Order Delivered',
        message: 'Your order #$orderId has been delivered. Thank you for shopping!',
        type: NotificationType.orderDelivered,
        createdAt: DateTime.now(),
        data: {'order_id': orderId},
      ),
    );
  }
  
  void addPromotionNotification(String title, String message) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: NotificationType.promotion,
        createdAt: DateTime.now(),
      ),
    );
  }

  void addStockAlert(StockAlert alert) {
    _stockAlerts.insert(0, alert);
    notifyListeners();
    _persist();
  }
}
