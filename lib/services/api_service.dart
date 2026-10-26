import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/network/dio_client.dart';
import '../data/models/order_model.dart';
import '../data/models/product_model.dart';
import '../data/models/customer_model.dart';
import '../data/models/dashboard_stats_model.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  Dio get dio => _dioClient.instance;

  /// تست اعتبار کلیدها و برقراری ارتباط با وردپرس/ووکامرس
  Future<Map<String, dynamic>> testConnection() async {
    try {
      // ابتدا بررسی وجود اندپوینت افزونه اختصاصی
      try {
        final res = await dio.get('${AppConstants.customPluginApiPath}/verify-connection');
        if (res.statusCode == 200 && res.data != null) {
          return {
            'success': true,
            'has_plugin': true,
            'store_name': res.data['store_name'] ?? 'فروشگاه ووکامرس',
            'currency_symbol': res.data['currency_symbol'] ?? 'تومان',
          };
        }
      } catch (_) {
        // در صورت عدم نصب افزونه، به وب‌سرویس اصلی ووکامرس ریدایرکت می‌شود
      }

      // تست مستقیم وب‌سرویس رسمی ووکامرس
      final wcRes = await dio.get('${AppConstants.wcApiPath}/system_status');
      if (wcRes.statusCode == 200 && wcRes.data != null) {
        final settings = wcRes.data['settings'] as Map<String, dynamic>? ?? {};
        return {
          'success': true,
          'has_plugin': false,
          'store_name': settings['site_title'] ?? 'فروشگاه ووکامرس',
          'currency_symbol': settings['currency_symbol'] ?? 'تومان',
        };
      }

      // فال‌بک سوم: خواندن سفارش اول
      final orderRes = await dio.get('${AppConstants.wcApiPath}/orders', queryParameters: {'per_page': 1});
      if (orderRes.statusCode == 200) {
        return {
          'success': true,
          'has_plugin': false,
          'store_name': 'فروشگاه ووکامرس',
          'currency_symbol': 'تومان',
        };
      }

      throw Exception('پاسخ سرور معتبر نبود.');
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    } catch (e) {
      throw Exception('خطا در اعتبارسنجی اتصال: $e');
    }
  }

  /// دریافت خلاصه آمار و هشدارهای داشبورد
  Future<DashboardStatsModel> getDashboardSummary({bool forceRefresh = false}) async {
    try {
      // تلاش برای خواندن از افزونه پرسرعت اختصاصی
      try {
        final res = await dio.get(
          '${AppConstants.customPluginApiPath}/dashboard-summary',
          queryParameters: forceRefresh ? {'force_refresh': '1'} : null,
        );
        if (res.statusCode == 200 && res.data != null && res.data['success'] == true) {
          return DashboardStatsModel.fromPluginJson(res.data);
        }
      } catch (_) {
        // در صورت عدم وجود افزونه، داده‌ها از اندپوینت‌های استاندارد ووکامرس استخراج می‌شوند
      }

      // فال‌بک با اندپوینت‌های رسمی ووکامرس
      final ordersRes = await dio.get('${AppConstants.wcApiPath}/orders', queryParameters: {'per_page': 10});
      final recentOrders = (ordersRes.data as List? ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      int pending = 0;
      int processing = 0;
      int onHold = 0;
      int completed = 0;
      double todaySales = 0;

      for (var o in recentOrders) {
        if (o.status == 'pending') pending++;
        if (o.status == 'processing') processing++;
        if (o.status == 'on-hold') onHold++;
        if (o.status == 'completed') {
          completed++;
          todaySales += o.total;
        }
      }

      return DashboardStatsModel(
        todaySales: todaySales,
        todayOrdersCount: recentOrders.length,
        monthSales: todaySales,
        monthOrdersCount: recentOrders.length,
        pendingOrders: pending,
        processingOrders: processing,
        onHoldOrders: onHold,
        completedOrders: completed,
        lowStockCount: 0,
        outOfStockCount: 0,
        orderStatuses: {
          'processing': processing,
          'pending': pending,
          'completed': completed,
          'on-hold': onHold,
        },
        recentOrders: recentOrders,
        weeklySales: [],
        storeName: 'فروشگاه من',
        storeUrl: dio.options.baseUrl,
        currency: 'IRT',
        currencySymbol: 'تومان',
      );
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    } catch (e) {
      throw Exception('خطا در دریافت اطلاعات داشبورد: $e');
    }
  }

  /// دریافت لیست سفارشات با صفحه‌بندی و فیلتر وضعیت یا جستجو
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'per_page': perPage,
        'orderby': 'date',
        'order': 'desc',
      };

      if (status != null && status.isNotEmpty && status != 'all') {
        params['status'] = status;
      }
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }

      final res = await dio.get('${AppConstants.wcApiPath}/orders', queryParameters: params);
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// دریافت جزییات کامل یک سفارش
  Future<OrderModel> getOrder(int id) async {
    try {
      final res = await dio.get('${AppConstants.wcApiPath}/orders/$id');
      return OrderModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// تغییر وضعیت سفارش
  Future<OrderModel> updateOrderStatus(int id, String newStatus) async {
    try {
      final res = await dio.put(
        '${AppConstants.wcApiPath}/orders/$id',
        data: {'status': newStatus},
      );
      return OrderModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// دریافت یادداشت‌های سفارش
  Future<List<OrderNote>> getOrderNotes(int orderId) async {
    try {
      final res = await dio.get('${AppConstants.wcApiPath}/orders/$orderId/notes');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((e) => OrderNote.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// افزودن یادداشت جدید به سفارش
  Future<OrderNote> addOrderNote(int orderId, String note, bool customerNote) async {
    try {
      final res = await dio.post(
        '${AppConstants.wcApiPath}/orders/$orderId/notes',
        data: {
          'note': note,
          'customer_note': customerNote,
        },
      );
      return OrderNote.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// دریافت لیست محصولات با فیلتر موجودی، دسته‌بندی و جستجو
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? stockStatus,
    int? categoryId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'per_page': perPage,
        'orderby': 'date',
        'order': 'desc',
      };

      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }
      if (stockStatus != null && stockStatus.isNotEmpty && stockStatus != 'all') {
        params['stock_status'] = stockStatus;
      }
      if (categoryId != null && categoryId > 0) {
        params['category'] = categoryId.toString();
      }

      final res = await dio.get('${AppConstants.wcApiPath}/products', queryParameters: params);
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// ویرایش سریع قیمت و موجودی محصول
  Future<ProductModel> quickUpdateProduct(
    int id, {
    double? regularPrice,
    double? salePrice,
    int? stockQuantity,
    String? stockStatus,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (regularPrice != null) {
        body['regular_price'] = regularPrice.toString();
      }
      if (salePrice != null) {
        body['sale_price'] = salePrice > 0 ? salePrice.toString() : '';
      }
      if (stockQuantity != null) {
        body['manage_stock'] = true;
        body['stock_quantity'] = stockQuantity;
        body['stock_status'] = stockQuantity > 0 ? 'instock' : 'outofstock';
      }
      if (stockStatus != null) {
        body['stock_status'] = stockStatus;
      }
      if (status != null) {
        body['status'] = status;
      }

      final res = await dio.put('${AppConstants.wcApiPath}/products/$id', data: body);
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// ویرایش کامل محصول
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final res = await dio.put('${AppConstants.wcApiPath}/products/$id', data: data);
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// ایجاد محصول جدید
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final res = await dio.post('${AppConstants.wcApiPath}/products', data: data);
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// دریافت لیست مشتریان
  Future<List<CustomerModel>> getCustomers({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'per_page': perPage,
        'role': 'all',
      };
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }

      final res = await dio.get('${AppConstants.wcApiPath}/customers', queryParameters: params);
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_dioClient.formatErrorMessage(e));
    }
  }

  /// دریافت رویدادها و اعلان‌های ثبت شده در افزونه وردپرس
  Future<List<Map<String, dynamic>>> getRecentNotifications() async {
    try {
      final res = await dio.get('${AppConstants.customPluginApiPath}/recent-notifications');
      if (res.statusCode == 200 && res.data != null && res.data['notifications'] is List) {
        return List<Map<String, dynamic>>.from(res.data['notifications']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
