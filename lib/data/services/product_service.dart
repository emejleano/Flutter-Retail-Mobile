import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/paginated_response.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService;

  ProductService({ApiService? apiService})
  : _apiService = apiService ?? ApiService.shared;

  /// Get list of sub-categories, optionally filtered by category
  Future<List<String>> getSubCategories({String? category}) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final response = await _apiService.get(
      ApiConstants.productSubCategories,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final subCategories = response['sub_categories'];
    if (subCategories is List) {
      return subCategories.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<PaginatedResponse<Product>> getProducts({
    String? search,
    String? category,
    String? subCategory,
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
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (subCategory != null && subCategory.isNotEmpty) {
      queryParams['sub_category'] = subCategory;
    }

    final response = await _apiService.get(
      ApiConstants.products,
      queryParams: queryParams,
    );

    final unwrapped = unwrapPaginator(response);
    final rawList = unwrapped['data'] ?? response['data'];
    final list = rawList is List ? rawList : const <dynamic>[];

    final data = list
        .whereType<Map<String, dynamic>>()
        .map((e) => Product.fromJson(e))
        .toList();

    return PaginatedResponse<Product>(
      currentPage: (unwrapped['current_page'] ?? response['current_page'] ?? 1) as int,
      data: data,
      perPage: (unwrapped['per_page'] ?? response['per_page'] ?? perPage) as int,
      total: (unwrapped['total'] ?? response['total'] ?? data.length) as int,
      lastPage: (unwrapped['last_page'] ?? response['last_page'] ?? 1) as int,
    );
  }

  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _apiService.get('${ApiConstants.products}/$productId');
      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await _apiService.post(
      ApiConstants.products,
      body: product.toJson(),
    );
    return Product.fromJson(response['data']);
  }

  Future<Product> updateProduct(String productId, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiConstants.products}/$productId',
      body: data,
    );
    return Product.fromJson(response['data']);
  }

  Future<void> deleteProduct(String productId) async {
    await _apiService.delete('${ApiConstants.products}/$productId');
  }

  Future<Product?> searchByBarcode(String barcode) async {
    // First try to get product by exact product_id (QR code contains product_id)
    final productById = await getProductById(barcode);
    if (productById != null) {
      return productById;
    }
    
    // Fallback: search by product name or partial match
    final response = await getProducts(search: barcode, perPage: 1);
    if (response.data.isNotEmpty) {
      return response.data.first;
    }
    return null;
  }
}
