import '../../core/constants/api_constants.dart';
import '../models/cart_item_model.dart';
import 'api_service.dart';

class CartService {
  final ApiService _apiService;

  CartService({ApiService? apiService})
      : _apiService = apiService ?? ApiService.shared;

  /// Get current user's cart from backend
  Future<BackendCart> getCart() async {
    final response = await _apiService.get(ApiConstants.cart);
    return BackendCart.fromJson(response);
  }

  /// Add item to cart
  /// If product already exists, quantity will be increased (additive)
  Future<Map<String, dynamic>> addItem({
    required String productId,
    required int quantity,
  }) async {
    final response = await _apiService.post(
      ApiConstants.cartItems,
      body: {
        'product_id': productId,
        'quantity': quantity,
      },
    );
    return response;
  }

  /// Update cart item quantity
  Future<Map<String, dynamic>> updateItem({
    required int itemId,
    required int quantity,
  }) async {
    final response = await _apiService.patch(
      '${ApiConstants.cartItems}/$itemId',
      body: {'quantity': quantity},
    );
    return response;
  }

  /// Remove item from cart
  Future<void> removeItem(int itemId) async {
    await _apiService.delete('${ApiConstants.cartItems}/$itemId');
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    await _apiService.delete(ApiConstants.cart);
  }

  /// Checkout cart (all items in cart)
  /// Customer flow: server infers user + order_id and checks out backend cart.
  Future<Map<String, dynamic>> checkoutCart({
    required int dateId,
    required int shipDateId,
    required String regionId,
    double discount = 0.0,
  }) async {
    return _apiService.post(
      ApiConstants.checkout,
      body: {
        'date_id': dateId,
        'ship_date_id': shipDateId,
        'region_id': regionId,
        'discount': discount,
      },
    );
  }

  /// Checkout single item (not from cart)
  Future<Map<String, dynamic>> checkoutSingleItem({
    required int dateId,
    required int shipDateId,
    required String productId,
    required String regionId,
    required int quantity,
    double discount = 0.0,
  }) async {
    final response = await _apiService.post(
      ApiConstants.checkout,
      body: {
        'date_id': dateId,
        'ship_date_id': shipDateId,
        'product_id': productId,
        'region_id': regionId,
        'quantity': quantity,
        'discount': discount,
      },
    );
    return response;
  }

  /// Checkout local cart items (when backend cart is unavailable)
  /// Fallback: calls customer checkout per item (single-item checkout).
  Future<Map<String, dynamic>> checkoutLocalCart({
    required List<CartItem> items,
    required int dateId,
    required int shipDateId,
    required String regionId,
    double discount = 0.0,
  }) async {
    if (items.isEmpty) {
      throw ApiException('Cart is empty');
    }

    Map<String, dynamic>? lastResponse;
    double totalSales = 0.0;

    for (final item in items) {
      final unitPrice = item.product.avgUnitPrice ?? 0.0;
      totalSales += unitPrice * item.quantity * (1 - discount);

      lastResponse = await checkoutSingleItem(
        dateId: dateId,
        shipDateId: shipDateId,
        productId: item.product.productId,
        regionId: regionId,
        quantity: item.quantity,
        discount: discount,
      );
    }

    return lastResponse ??
        {
          'data': {
            'total_sales': totalSales,
          }
        };
  }
}
