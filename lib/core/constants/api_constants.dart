import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    // NOTE:
    // - Windows/macOS/Linux/iOS: localhost usually works.
    // - Android emulator: localhost points to the emulator itself; use 10.0.2.2.
    // - Physical device: use your PC's LAN IP (e.g., http://192.168.x.x:8000/api).
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'https://api.mero.my.id/api';
    }
    return 'https://api.mero.my.id/api';
  }
  
  // Auth
  static const String login = '/login';
  static const String customerLogin = '/customer-login';
  static const String completeProfile = '/complete-profile';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String refresh = '/refresh';
  static const String changePassword = '/change-password';
  
  // Dashboard
  static const String dashboard = '/dashboard';
  
  // Products
  static const String products = '/products';
  static const String productSubCategories = '/products/sub-categories';
  
  // Customers
  static const String customers = '/customers';
  
  // Regions
  static const String regions = '/regions';
  
  // Sales
  static const String sales = '/sales';
  static const String checkout = '/checkout';
  
  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
