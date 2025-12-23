import 'package:flutter/material.dart';
import '../data/models/sale_model.dart';
import '../data/models/paginated_response.dart';
import '../data/services/sale_service.dart';
import '../data/services/api_service.dart';

class SaleProvider extends ChangeNotifier {
  final SaleService _saleService;
  
  List<Sale> _sales = [];
  PaginatedResponse<Sale>? _paginatedResponse;
  bool _isLoading = false;
  String? _error;
  
  // Filters
  String? _productId;
  String? _customerId;
  String? _regionId;
  String? _startDate;
  String? _endDate;
  String? _sortBy;
  String? _sortDir;
  String? _orderId;
  
  SaleProvider({SaleService? saleService})
      : _saleService = saleService ?? SaleService();
  
  List<Sale> get sales => _sales;
  PaginatedResponse<Sale>? get paginatedResponse => _paginatedResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _paginatedResponse?.hasNextPage ?? false;
  int get currentPage => _paginatedResponse?.currentPage ?? 1;
  int get totalItems => _paginatedResponse?.total ?? 0;
  
  Future<void> loadSales({
    bool refresh = false,
    String? productId,
    String? customerId,
    String? regionId,
    String? startDate,
    String? endDate,
    String? sortBy,
    String? sortDir,
    String? orderId,
  }) async {
    if (refresh) {
      _sales = [];
      _paginatedResponse = null;
    }
    
    if (productId != null) _productId = productId;
    if (customerId != null) _customerId = customerId;
    if (regionId != null) _regionId = regionId;
    if (startDate != null) _startDate = startDate;
    if (endDate != null) _endDate = endDate;
    if (sortBy != null) _sortBy = sortBy;
    if (sortDir != null) _sortDir = sortDir;
    if (orderId != null) _orderId = orderId;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _saleService.getSales(
        productId: _productId,
        customerId: _customerId,
        regionId: _regionId,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        sortDir: _sortDir,
        orderId: _orderId,
        page: 1,
      );
      
      _sales = response.data;
      _paginatedResponse = response;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load sales';
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
      final response = await _saleService.getSales(
        productId: _productId,
        customerId: _customerId,
        regionId: _regionId,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        sortDir: _sortDir,
        orderId: _orderId,
        page: currentPage + 1,
      );
      
      _sales.addAll(response.data);
      _paginatedResponse = response;
    } catch (e) {
      // Silent fail for pagination
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createSale(Sale sale) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final newSale = await _saleService.createSale(sale);
      _sales.insert(0, newSale);
      
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
  
  Future<bool> updateSale(int factId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedSale = await _saleService.updateSale(factId, data);
      final index = _sales.indexWhere((s) => s.factId == factId);
      if (index != -1) {
        _sales[index] = updatedSale;
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
  
  Future<bool> deleteSale(int factId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _saleService.deleteSale(factId);
      _sales.removeWhere((s) => s.factId == factId);
      
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
    _productId = null;
    _customerId = null;
    _regionId = null;
    _startDate = null;
    _endDate = null;
    _sortBy = null;
    _sortDir = null;
    _orderId = null;
    loadSales(refresh: true);
  }
}
