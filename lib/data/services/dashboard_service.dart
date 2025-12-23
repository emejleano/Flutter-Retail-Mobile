import '../../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService({ApiService? apiService})
  : _apiService = apiService ?? ApiService.shared;

  Future<DashboardData> getDashboard({
    String? from,
    String? to,
    String? category,
    String? region,
    int? trendDays,
  }) async {
    final queryParams = <String, dynamic>{};

    if (from != null && from.trim().isNotEmpty) queryParams['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) queryParams['to'] = to.trim();
    if (category != null && category.trim().isNotEmpty) {
      queryParams['category'] = category.trim();
    }
    if (region != null && region.trim().isNotEmpty) queryParams['region'] = region.trim();

    if (trendDays != null) {
      final clamped = trendDays.clamp(1, 365);
      queryParams['trend_days'] = clamped;
    }

    final response = await _apiService.get(
      ApiConstants.dashboard,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    return DashboardData.fromJson(response);
  }
}
