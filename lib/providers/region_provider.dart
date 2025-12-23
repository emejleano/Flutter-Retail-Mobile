import 'package:flutter/material.dart';
import '../data/models/region_model.dart';
import '../data/services/region_service.dart';
import '../data/services/api_service.dart';

class RegionProvider extends ChangeNotifier {
  final RegionService _regionService;
  
  List<Region> _regions = [];
  bool _isLoading = false;
  String? _error;
  
  RegionProvider({RegionService? regionService})
      : _regionService = regionService ?? RegionService();
  
  List<Region> get regions => _regions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalItems => _regions.length;
  
  Future<void> loadRegions({
    bool refresh = false,
  }) async {
    if (refresh) {
      _regions = [];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _regions = await _regionService.getRegions();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load regions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadMore() async {
    // No pagination for /api/regions
    return;
  }
  
  Future<bool> createRegion(Region region) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final newRegion = await _regionService.createRegion(region);
      _regions.insert(0, newRegion);
      
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
  
  Future<bool> updateRegion(String regionId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedRegion = await _regionService.updateRegion(regionId, data);
      final index = _regions.indexWhere((r) => r.regionId == regionId);
      if (index != -1) {
        _regions[index] = updatedRegion;
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
  
  Future<bool> deleteRegion(String regionId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _regionService.deleteRegion(regionId);
      _regions.removeWhere((r) => r.regionId == regionId);
      
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
    loadRegions(refresh: true);
  }
}
