import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<ProductModel> _products = [];
  String _searchQuery = '';
  String _selectedStockStatus = 'all';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _hasMore = true;
  String? _errorMessage;

  ProductsProvider(this._apiService);

  List<ProductModel> get products => _products;
  String get searchQuery => _searchQuery;
  String get selectedStockStatus => _selectedStockStatus;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products.clear();
    }

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getProducts(
        page: _currentPage,
        perPage: 20,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        stockStatus: _selectedStockStatus == 'all' ? null : _selectedStockStatus,
      );

      if (fetched.length < 20) {
        _hasMore = false;
      }

      if (refresh) {
        _products = fetched;
      } else {
        _products.addAll(fetched);
      }

      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    loadProducts(refresh: true);
  }

  void filterByStock(String status) {
    if (_selectedStockStatus == status) return;
    _selectedStockStatus = status;
    loadProducts(refresh: true);
  }

  /// ویرایش سریع قیمت و موجودی محصول
  Future<bool> quickUpdateProduct(
    int productId, {
    double? regularPrice,
    double? salePrice,
    int? stockQuantity,
    String? stockStatus,
    String? status,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final updated = await _apiService.quickUpdateProduct(
        productId,
        regularPrice: regularPrice,
        salePrice: salePrice,
        stockQuantity: stockQuantity,
        stockStatus: stockStatus,
        status: status,
      );

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updated;
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

  /// ذخیره کامل محصول جدید یا ویرایش شده
  Future<bool> saveProduct({int? id, required Map<String, dynamic> data}) async {
    _isUpdating = true;
    notifyListeners();

    try {
      if (id != null) {
        final updated = await _apiService.updateProduct(id, data);
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = updated;
        }
      } else {
        final created = await _apiService.createProduct(data);
        _products.insert(0, created);
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
}
