import '../../core/constants/api_constants.dart';
import '../models/sale_model.dart';
import '../models/paginated_response.dart';
import 'api_service.dart';

class SaleService {
  final ApiService _apiService;

  SaleService({ApiService? apiService})
  : _apiService = apiService ?? ApiService.shared;

  Future<PaginatedResponse<Sale>> getSales({
    String? productId,
    String? customerId,
    String? regionId,
    String? startDate,
    String? endDate,
    double? minSales,
    double? maxSales,
    String? sortBy,
    String? sortDir,
    String? orderId,
    int page = 1,
    int perPage = 20,
  }) async {
    Map<String, dynamic> unwrapPaginator(Map<String, dynamic> response) {
      final dynamic data = response['data'];
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data;
      }
      return response;
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (productId != null && productId.isNotEmpty) {
      queryParams['product_id'] = productId;
    }
    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customer_id'] = customerId;
    }
    if (regionId != null && regionId.isNotEmpty) {
      queryParams['region_id'] = regionId;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }
    if (minSales != null) {
      queryParams['min_sales'] = minSales;
    }
    if (maxSales != null) {
      queryParams['max_sales'] = maxSales;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }
    if (sortDir != null && sortDir.isNotEmpty) {
      queryParams['sort_dir'] = sortDir;
    }
    if (orderId != null && orderId.isNotEmpty) {
      queryParams['order_id'] = orderId;
    }

    final response = await _apiService.get(
      ApiConstants.sales,
      queryParams: queryParams,
    );

      final unwrapped = unwrapPaginator(response);

    // Handle different response formats from API
    List<Sale> data = [];

    final rawList = unwrapped['data'] ?? response['data'];
    if (rawList is List) {
      data = rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => Sale.fromJson(e))
          .toList();
    } else if (response['sales'] is List) {
      // Alternative response format
      data = (response['sales'] as List<dynamic>)
          .map((e) => Sale.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.containsKey('fact_id')) {
      // Single sale response wrapped
      data = [Sale.fromJson(response)];
    }

    return PaginatedResponse<Sale>(
      currentPage: (unwrapped['current_page'] ?? response['current_page'] ?? response['meta']?['current_page'] ?? 1) as int,
      data: data,
      perPage: (unwrapped['per_page'] ?? response['per_page'] ?? response['meta']?['per_page'] ?? perPage) as int,
      total: (unwrapped['total'] ?? response['total'] ?? response['meta']?['total'] ?? data.length) as int,
      lastPage: (unwrapped['last_page'] ?? response['last_page'] ?? response['meta']?['last_page'] ?? 1) as int,
    );
  }

  Future<Sale> getSaleById(int factId) async {
    final response = await _apiService.get('${ApiConstants.sales}/$factId');
    return Sale.fromJson(response);
  }

  Future<Sale> createSale(Sale sale) async {
    final response = await _apiService.post(
      ApiConstants.sales,
      body: sale.toJson(),
    );
    return Sale.fromJson(response['data']);
  }

  Future<Sale> updateSale(int factId, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiConstants.sales}/$factId',
      body: data,
    );
    return Sale.fromJson(response['data']);
  }

  Future<void> deleteSale(int factId) async {
    await _apiService.delete('${ApiConstants.sales}/$factId');
  }
}
