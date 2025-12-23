import 'package:flutter/material.dart';
import '../data/models/dashboard_model.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  static const String genericErrorKey = '__generic_dashboard_error__';

  final DashboardService _dashboardService;
  
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  // Persist last-used filters so refresh/tab refetch keeps current view.
  String? _from;
  String? _to;
  String? _category;
  String? _region;
  int _trendDays = 7;
  
  DashboardProvider({DashboardService? dashboardService})
      : _dashboardService = dashboardService ?? DashboardService();
  
  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _dashboardData != null;

  String? get from => _from;
  String? get to => _to;
  String? get category => _category;
  String? get region => _region;
  int get trendDays => _trendDays;
  
  Future<void> loadDashboard({
    String? from,
    String? to,
    String? category,
    String? region,
    int? trendDays,
  }) async {
    _isLoading = true;
    _error = null;

    // Update stored filters (null means clear filter).
    if (from != null || to != null || category != null || region != null) {
      _from = from;
      _to = to;
      _category = category;
      _region = region;
    }

    if (trendDays != null) {
      _trendDays = trendDays.clamp(1, 365);
    }
    notifyListeners();
    
    try {
      _dashboardData = await _dashboardService.getDashboard(
        from: _from,
        to: _to,
        category: _category,
        region: _region,
        trendDays: _trendDays,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = genericErrorKey;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refresh() async {
    await loadDashboard();
  }

  void resetFilters() {
    _from = null;
    _to = null;
    _category = null;
    _region = null;
    _trendDays = 7;
    notifyListeners();
  }
}
