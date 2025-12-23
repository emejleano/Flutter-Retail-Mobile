import 'package:flutter/foundation.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/services/cart_service.dart';
import '../data/services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService;
  
  // Local cart state (fallback when backend cart unavailable)
  final Map<String, CartItem> _localItems = {};
  
  // Backend cart state
  BackendCart? _backendCart;
  bool _useLocalCart = true; // Start with local, try backend on load
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  bool _orderSuccess = false;
  String? _lastOrderId;
  double _lastOrderTotal = 0.0;

  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  // Getters - Use backend or local depending on mode
  List<BackendCartItem> get items {
    if (_useLocalCart) {
      // Convert local items to BackendCartItem format for compatibility
      // Use customer prices (with 5% markup)
      return _localItems.values.map((item) => BackendCartItem(
        id: 0,
        productId: item.product.productId,
        quantity: item.quantity,
        unitPrice: item.customerPrice,
        subtotal: item.subtotal,
        product: item.product,
      )).toList();
    }
    return _backendCart?.items ?? [];
  }
  
  int get itemCount => _useLocalCart ? _localItems.length : (_backendCart?.itemCount ?? 0);
  int get totalQuantity => _useLocalCart 
      ? _localItems.values.fold(0, (sum, item) => sum + item.quantity)
      : (_backendCart?.totalQuantity ?? 0);
  /// Total amount with customer markup (5%)
  double get totalAmount {
    if (_useLocalCart) {
      return _localItems.values.fold(0.0, (sum, item) => sum + item.subtotal);
    }
    // Backend cart - apply 5% markup
    return _backendCart?.items.fold<double>(0.0, (sum, item) => sum + item.customerSubtotal) ?? 0.0;
  }
  bool get isEmpty => _useLocalCart ? _localItems.isEmpty : (_backendCart?.isEmpty ?? true);
  bool get isNotEmpty => !isEmpty;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  bool get orderSuccess => _orderSuccess;
  String? get lastOrderId => _lastOrderId;
  double get lastOrderTotal => _lastOrderTotal;

  // Check if product is in cart
  bool isInCart(String productId) {
    if (_useLocalCart) {
      return _localItems.containsKey(productId);
    }
    return _backendCart?.items.any((item) => item.productId == productId) ?? false;
  }

  // Get quantity for a product
  int getQuantity(String productId) {
    if (_useLocalCart) {
      return _localItems[productId]?.quantity ?? 0;
    }
    final item = _backendCart?.items.cast<BackendCartItem?>().firstWhere(
      (item) => item?.productId == productId,
      orElse: () => null,
    );
    return item?.quantity ?? 0;
  }

  // Get cart item ID for a product
  int? getCartItemId(String productId) {
    if (_useLocalCart) return null;
    final item = _backendCart?.items.cast<BackendCartItem?>().firstWhere(
      (item) => item?.productId == productId,
      orElse: () => null,
    );
    return item?.id;
  }

  // Load cart - try backend first, fallback to local
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _backendCart = await _cartService.getCart();
      _useLocalCart = false;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      // If 404 or not found, backend cart API doesn't exist - use local
      if (e.statusCode == 404 || e.statusCode == 401) {
        _useLocalCart = true;
      } else {
        _error = e.message;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Use local cart on any error
      _useLocalCart = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product to cart (local or backend)
  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (_useLocalCart) {
      // Local cart mode
      if (_localItems.containsKey(product.productId)) {
        _localItems[product.productId]!.quantity += quantity;
      } else {
        _localItems[product.productId] = CartItem(product: product, quantity: quantity);
      }
      notifyListeners();
      return true;
    }

    // Backend cart mode
    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.addItem(
        productId: product.productId,
        quantity: quantity,
      );
      // Reload cart to get updated state
      await loadCart();
      _isSyncing = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSyncing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add to cart';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Remove product from cart (local or backend)
  Future<bool> removeFromCart(String productId) async {
    if (_useLocalCart) {
      _localItems.remove(productId);
      notifyListeners();
      return true;
    }

    final itemId = getCartItemId(productId);
    if (itemId == null) return false;

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.removeItem(itemId);
      // Reload cart to get updated state
      await loadCart();
      _isSyncing = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSyncing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to remove from cart';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Update quantity (local or backend)
  Future<bool> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(productId);
    }

    if (_useLocalCart) {
      if (_localItems.containsKey(productId)) {
        _localItems[productId]!.quantity = quantity;
        notifyListeners();
      }
      return true;
    }

    final itemId = getCartItemId(productId);
    if (itemId == null) return false;

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.updateItem(
        itemId: itemId,
        quantity: quantity,
      );
      // Reload cart to get updated state
      await loadCart();
      _isSyncing = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSyncing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update cart';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Increment quantity (backend)
  Future<bool> incrementQuantity(String productId) async {
    final currentQty = getQuantity(productId);
    return updateQuantity(productId, currentQty + 1);
  }

  // Decrement quantity (backend)
  Future<bool> decrementQuantity(String productId) async {
    final currentQty = getQuantity(productId);
    if (currentQty <= 1) {
      return removeFromCart(productId);
    }
    return updateQuantity(productId, currentQty - 1);
  }

  // Clear cart (local or backend)
  Future<bool> clearCart() async {
    if (_useLocalCart) {
      _localItems.clear();
      _orderSuccess = false;
      _lastOrderId = null;
      notifyListeners();
      return true;
    }

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.clearCart();
      _backendCart = BackendCart(items: [], total: 0);
      _orderSuccess = false;
      _lastOrderId = null;
      _isSyncing = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSyncing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to clear cart';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Calculate discount (simple rule based on total)
  double get discountRate {
    if (totalAmount > 1000) return 0.15;
    if (totalAmount > 500) return 0.10;
    if (totalAmount > 200) return 0.05;
    return 0.0;
  }

  double get discountAmount => totalAmount * discountRate;
  double get finalTotal => totalAmount - discountAmount;

  // Checkout cart - creates sales records
  Future<bool> submitOrder({
    required String regionId,
  }) async {
    if (isEmpty) {
      _error = 'Cart is empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _orderSuccess = false;
    notifyListeners();

    try {
      // Date ID format: YYYYMMDD
      final now = DateTime.now();
      final dateId = int.parse('${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}');
      
      // Ship date = order date + 3 days
      final shipDate = now.add(const Duration(days: 3));
      final shipDateId = int.parse('${shipDate.year}${shipDate.month.toString().padLeft(2, '0')}${shipDate.day.toString().padLeft(2, '0')}');

      // Save total before checkout
      _lastOrderTotal = finalTotal;

      if (_useLocalCart) {
        // Local cart mode - use checkoutLocalCart
        final response = await _cartService.checkoutLocalCart(
          items: _localItems.values.toList(),
          dateId: dateId,
          shipDateId: shipDateId,
          regionId: regionId,
          discount: discountRate,
        );
        
        _lastOrderId = response['data']?['order_id']?.toString();
        if (response['data']?['total_sales'] != null) {
          _lastOrderTotal = (response['data']['total_sales'] as num).toDouble();
        }
        
        // Clear local cart
        _localItems.clear();
      } else {
        // Backend cart mode
        final response = await _cartService.checkoutCart(
          dateId: dateId,
          shipDateId: shipDateId,
          regionId: regionId,
          discount: discountRate,
        );

        // Parse response
        if (response['data'] != null) {
          final data = response['data'];
          _lastOrderId = data['order_id']?.toString();
          if (data['total_sales'] != null) {
            _lastOrderTotal = (data['total_sales'] as num).toDouble();
          }
        }
        
        // Cart is cleared by backend
        _backendCart = BackendCart(items: [], total: 0);
      }
      
      _lastOrderId ??= 'ORD-${now.millisecondsSinceEpoch}';
      _orderSuccess = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset order status
  void resetOrderStatus() {
    _orderSuccess = false;
    _lastOrderId = null;
    _lastOrderTotal = 0.0;
    _error = null;
    notifyListeners();
  }

  // Clear local error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
