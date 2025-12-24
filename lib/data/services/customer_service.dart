import '../../core/constants/api_constants.dart';
import '../models/customer_model.dart';
import '../models/paginated_response.dart';
import 'api_service.dart';

class CustomerService {
  final ApiService _apiService;

  CustomerService({ApiService? apiService})
  : _apiService = apiService ?? ApiService.shared;

  Future<PaginatedResponse<Customer>> getCustomers({
    String? search,
    String? segment,
    int page = 1,
    int perPage = 20,
  }) async {
    Map<String, dynamic> unwrapPaginator(Map<String, dynamic> response) {
      final data = response['data'];
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data;
      }
      return response;
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (segment != null && segment.isNotEmpty) {
      queryParams['segment'] = segment;
    }

    final response = await _apiService.get(
      ApiConstants.customers,
      queryParams: queryParams,
    );

    final unwrapped = unwrapPaginator(response);
    final rawList = unwrapped['data'] ?? response['data'];
    final list = rawList is List ? rawList : const <dynamic>[];

    final data = list
        .whereType<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .toList();

    return PaginatedResponse<Customer>(
      currentPage: (unwrapped['current_page'] ?? response['current_page'] ?? 1) as int,
      data: data,
      perPage: (unwrapped['per_page'] ?? response['per_page'] ?? perPage) as int,
      total: (unwrapped['total'] ?? response['total'] ?? data.length) as int,
      lastPage: (unwrapped['last_page'] ?? response['last_page'] ?? 1) as int,
    );
  }

  Future<Customer> getCustomerById(String customerId) async {
    final response = await _apiService.get('${ApiConstants.customers}/$customerId');
    return Customer.fromJson(response);
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _apiService.post(
      ApiConstants.customers,
      body: customer.toJson(),
    );
    return Customer.fromJson(response['data']);
  }

  Future<Customer> updateCustomer(String customerId, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiConstants.customers}/$customerId',
      body: data,
    );
    return Customer.fromJson(response['data']);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _apiService.delete('${ApiConstants.customers}/$customerId');
  }
}
