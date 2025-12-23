import 'package:flutter/material.dart';
import '../data/models/customer_model.dart';
import '../data/models/paginated_response.dart';
import '../data/services/customer_service.dart';
import '../data/services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService;
  
  List<Customer> _customers = [];
  PaginatedResponse<Customer>? _paginatedResponse;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedSegment;
  
  CustomerProvider({CustomerService? customerService})
      : _customerService = customerService ?? CustomerService();
  
  List<Customer> get customers => _customers;
  PaginatedResponse<Customer>? get paginatedResponse => _paginatedResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedSegment => _selectedSegment;
  bool get hasMore => _paginatedResponse?.hasNextPage ?? false;
  int get currentPage => _paginatedResponse?.currentPage ?? 1;
  int get totalItems => _paginatedResponse?.total ?? 0;
  
  Future<void> loadCustomers({
    bool refresh = false,
    String? search,
    String? segment,
  }) async {
    if (refresh) {
      _customers = [];
      _paginatedResponse = null;
    }
    
    if (search != null) _searchQuery = search;
    if (segment != null) _selectedSegment = segment;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _customerService.getCustomers(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        segment: _selectedSegment,
        page: 1,
      );
      
      _customers = response.data;
      _paginatedResponse = response;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load customers';
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
      final response = await _customerService.getCustomers(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        segment: _selectedSegment,
        page: currentPage + 1,
      );
      
      _customers.addAll(response.data);
      _paginatedResponse = response;
    } catch (e) {
      // Silent fail for pagination
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createCustomer(Customer customer) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final newCustomer = await _customerService.createCustomer(customer);
      _customers.insert(0, newCustomer);
      
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
  
  Future<bool> updateCustomer(String customerId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedCustomer = await _customerService.updateCustomer(customerId, data);
      final index = _customers.indexWhere((c) => c.customerId == customerId);
      if (index != -1) {
        _customers[index] = updatedCustomer;
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
  
  Future<bool> deleteCustomer(String customerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _customerService.deleteCustomer(customerId);
      _customers.removeWhere((c) => c.customerId == customerId);
      
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
    _selectedSegment = null;
    loadCustomers(refresh: true);
  }
}
