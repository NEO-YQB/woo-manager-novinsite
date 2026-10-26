import 'package:flutter/foundation.dart';
import '../data/models/dashboard_stats_model.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;

  DashboardStatsModel _stats = DashboardStatsModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider(this._apiService);

  DashboardStatsModel get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _apiService.getDashboardSummary(forceRefresh: forceRefresh);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
