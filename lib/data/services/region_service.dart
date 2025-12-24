import '../../core/constants/api_constants.dart';
import '../models/region_model.dart';
import 'api_service.dart';

class RegionService {
  final ApiService _apiService;

  RegionService({ApiService? apiService})
  : _apiService = apiService ?? ApiService.shared;

  Future<List<Region>> getRegions() async {
    final response = await _apiService.getList(ApiConstants.regions);
    return response
        .map((e) => Region.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Region> getRegionById(String regionId) async {
    final response = await _apiService.get('${ApiConstants.regions}/$regionId');
    return Region.fromJson(response);
  }

  Future<Region> createRegion(Region region) async {
    final response = await _apiService.post(
      ApiConstants.regions,
      body: region.toJson(),
    );
    return Region.fromJson(response['data']);
  }

  Future<Region> updateRegion(String regionId, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiConstants.regions}/$regionId',
      body: data,
    );
    return Region.fromJson(response['data']);
  }

  Future<void> deleteRegion(String regionId) async {
    await _apiService.delete('${ApiConstants.regions}/$regionId');
  }
}
