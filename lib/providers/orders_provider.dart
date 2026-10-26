import 'package:flutter/foundation.dart';
import '../data/models/order_model.dart';
import '../services/api_service.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<OrderModel> _orders = [];
  String _selectedStatus = 'all';
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _hasMore = true;
  String? _errorMessage;

  OrdersProvider(this._apiService);

  List<OrderModel> get orders => _orders;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _orders.clear();
    }

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getOrders(
        page: _currentPage,
        perPage: 20,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (fetched.length < 20) {
        _hasMore = false;
      }

      if (refresh) {
        _orders = fetched;
      } else {
        _orders.addAll(fetched);
      }

      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByStatus(String status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    loadOrders(refresh: true);
  }

  void searchOrders(String query) {
    _searchQuery = query;
    loadOrders(refresh: true);
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateOrderStatus(orderId, newStatus);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updated;
      }
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<OrderNote>> getOrderNotes(int orderId) async {
    try {
      return await _apiService.getOrderNotes(orderId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> addOrderNote(int orderId, String note, bool customerNote) async {
    try {
      await _apiService.addOrderNote(orderId, note, customerNote);
      return true;
    } catch (e) {
      return false;
    }
  }
}
