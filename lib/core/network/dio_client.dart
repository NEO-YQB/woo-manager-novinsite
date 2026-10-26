import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'WooCommerce-Flutter-Manager/1.0',
        },
      ),
    );

    // نادیده گرفتن خطاهای گواهی SSL برای سایت‌های لوکال یا استیجینگ
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  void configureAuth({
    required String siteUrl,
    required String consumerKey,
    required String consumerSecret,
    String? appToken,
  }) {
    var cleanUrl = siteUrl.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    _dio.options.baseUrl = cleanUrl;

    // ایجاد توکن استاندارد Basic Auth برای ووکامرس
    final basicAuthCredentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
    _dio.options.headers['Authorization'] = 'Basic $basicAuthCredentials';

    if (appToken != null && appToken.isNotEmpty) {
      _dio.options.headers['x-woo-app-token'] = appToken;
    }
  }

  Dio get instance => _dio;

  String formatErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'مهلت اتصال به سرور فروشگاه به پایان رسید. لطفاً سرعت اینترنت را بررسی کنید.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return 'خطای دسترسی (۴۰۱/۴۰۳): کلیدهای API ووکامرس نامعتبر هستند یا دسترسی لازم را ندارید.';
        } else if (statusCode == 404) {
          return 'آدرس وب‌سرویس یافت نشد (۴۰۴). مطمئن شوید ووکامرس و پیوندهای یکتا فعال هستند.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'خطای داخلی سرور فروشگاه ($statusCode). لطفاً گزارش خطای وردپرس را بررسی کنید.';
        }
        return 'پاسخ نامعتبر از سرور فروشگاه ($statusCode).';
      case DioExceptionType.connectionError:
        return 'امکان برقراری ارتباط با وبسایت وجود ندارد. لطفاً از اتصال اینترنت و در دسترس بودن هاست مطمئن شوید.';
      case DioExceptionType.cancel:
        return 'درخواست لغو شد.';
      default:
        return 'خطای ناشناخته در ارتباط: ${error.message}';
    }
  }
}
