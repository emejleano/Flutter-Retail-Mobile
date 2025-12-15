import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';

class ApiService {
  /// Select base URL depending on platform.
  /// - Web: use localhost
  /// - Android (emulator): use 10.0.2.2
  /// - Other native platforms: use localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  /// Fetch dashboard summary
  static Future<DashboardModel> fetchDashboard() async {
    final uri = Uri.parse('$baseUrl/dashboard');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        return DashboardModel.fromJson(body);
      }
      throw Exception('Failed to load dashboard: ${res.statusCode} - ${res.body}');
    } catch (e) {
      throw Exception('Error fetching dashboard: ${e.toString()}');
    }
  }

  /// Fetch list of products
  static Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/products');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        List<dynamic> listData;
        if (decoded is List) {
          listData = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // common shapes: { data: [...] } or { products: [...] } or single map of items
          if (decoded['data'] is List) {
            listData = decoded['data'] as List<dynamic>;
          } else if (decoded['products'] is List) {
            listData = decoded['products'] as List<dynamic>;
          } else {
            // fallback: try to extract values if map of id->object
            listData = decoded.values.where((v) => v is Map || v is List).toList();
          }
        } else {
          throw Exception('Unexpected products response format');
        }

        return listData.map((e) {
          if (e is Map<String, dynamic>) return Product.fromJson(e);
          if (e is Map) return Product.fromJson(Map<String, dynamic>.from(e));
          throw Exception('Invalid product item');
        }).toList();
      }
      throw Exception('Failed to load products: ${res.statusCode} - ${res.body}');
    } catch (e) {
      throw Exception('Error fetching products: ${e.toString()}');
    }
  }

  /// Fetch customers (returns raw list of maps since Customer model is not defined)
  static Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final uri = Uri.parse('$baseUrl/customers');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        List<dynamic> listData;
        if (decoded is List) {
          listData = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is List) {
            listData = decoded['data'] as List<dynamic>;
          } else if (decoded['customers'] is List) {
            listData = decoded['customers'] as List<dynamic>;
          } else {
            // fallback: try values that are maps (e.g., id->object)
            final candidates = decoded.values.where((v) => v is List || v is Map).toList();
            if (candidates.isNotEmpty && candidates.first is List) {
              listData = candidates.first as List<dynamic>;
            } else {
              // nothing found — wrap the map itself as single-entry list
              listData = [decoded];
            }
          }
        } else {
          throw Exception('Unexpected customers response format');
        }

        return listData.map((e) {
          if (e is Map<String, dynamic>) return Map<String, dynamic>.from(e);
          if (e is Map) return Map<String, dynamic>.from(e);
          // If it's a primitive, wrap into a map with value
          return {'value': e};
        }).toList();
      }
      throw Exception('Failed to load customers: ${res.statusCode} - ${res.body}');
    } catch (e) {
      throw Exception('Error fetching customers: ${e.toString()}');
    }
  }

  /// Create a sale transaction. Returns true if created (status 201 or 200)
  static Future<bool> createSale(Sale sale) async {
    final uri = Uri.parse('$baseUrl/sales');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(sale.toJson()),
      );

      if (res.statusCode == 201 || res.statusCode == 200) return true;

      throw Exception('Failed to create sale: ${res.statusCode} - ${res.body}');
    } catch (e) {
      throw Exception('Error creating sale: ${e.toString()}');
    }
  }
}
