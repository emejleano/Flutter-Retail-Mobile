import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/paginated_response.dart';
import '../data/services/product_service.dart';
import '../data/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService;
  
  List<Product> _products = [];
  PaginatedResponse<Product>? _paginatedResponse;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  
  ProductProvider({ProductService? productService})
      : _productService = productService ?? ProductService();
  
  List<Product> get products => _products;
  PaginatedResponse<Product>? get paginatedResponse => _paginatedResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get hasMore => _paginatedResponse?.hasNextPage ?? false;
  int get currentPage => _paginatedResponse?.currentPage ?? 1;
  int get totalItems => _paginatedResponse?.total ?? 0;
  
  Future<void> loadProducts({
    bool refresh = false,
    String? search,
    String? category,
  }) async {
    if (refresh) {
      _products = [];
      _paginatedResponse = null;
    }
    
    if (search != null) _searchQuery = search;
    if (category != null) {
      // Empty string means "All" categories
      _selectedCategory = category.isEmpty ? null : category;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _productService.getProducts(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        page: 1,
      );
      
      _products = response.data;
      _paginatedResponse = response;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load products';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _productService.getProducts(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        page: currentPage + 1,
      );
      
      _products.addAll(response.data);
      _paginatedResponse = response;
    } catch (e) {
      // Silent fail for pagination
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Product?> searchByBarcode(String barcode) async {
    try {
      return await _productService.searchByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> createProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final newProduct = await _productService.createProduct(product);
      _products.insert(0, newProduct);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedProduct = await _productService.updateProduct(productId, data);
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _productService.deleteProduct(productId);
      _products.removeWhere((p) => p.productId == productId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    loadProducts(refresh: true);
  }
}
