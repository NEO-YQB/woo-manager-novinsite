import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';
import '../core/security/biometric_service.dart';
import '../core/security/secure_storage_service.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated, biometricRequired }

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _storageService;
  final BiometricService _biometricService;
  final DioClient _dioClient;
  late final ApiService _apiService;

  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  String _siteUrl = '';
  String _storeName = 'فروشگاه ووکامرس';
  String _currencySymbol = 'تومان';
  bool _biometricEnabled = false;

  AuthProvider({
    required SecureStorageService storageService,
    required BiometricService biometricService,
    required DioClient dioClient,
  })  : _storageService = storageService,
        _biometricService = biometricService,
        _dioClient = dioClient {
    _apiService = ApiService(_dioClient);
  }

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;
  String get siteUrl => _siteUrl;
  String get storeName => _storeName;
  String get currencySymbol => _currencySymbol;
  bool get biometricEnabled => _biometricEnabled;
  ApiService get apiService => _apiService;

  /// بررسی وضعیت لاگین اولیه هنگام اجرای اپ
  Future<void> checkAuthStatus({bool requireBiometrics = true}) async {
    final hasKeys = await _storageService.hasCredentials();
    if (!hasKeys) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final savedUrl = await _storageService.getSiteUrl();
    final savedKey = await _storageService.getConsumerKey();
    final savedSecret = await _storageService.getConsumerSecret();
    final savedToken = await _storageService.getAppToken();
    _storeName = (await _storageService.getStoreName()) ?? 'فروشگاه من';
    _currencySymbol = (await _storageService.getCurrencySymbol()) ?? 'تومان';
    _siteUrl = savedUrl ?? '';

    _dioClient.configureAuth(
      siteUrl: savedUrl!,
      consumerKey: savedKey!,
      consumerSecret: savedSecret!,
      appToken: savedToken,
    );

    if (requireBiometrics && _biometricEnabled) {
      _status = AuthStatus.biometricRequired;
      notifyListeners();
      await authenticateWithBiometrics();
    } else {
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  /// اعتبارسنجی بیومتریک برای عبور از صفحه قفل
  Future<bool> authenticateWithBiometrics() async {
    final success = await _biometricService.authenticate();
    if (success) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// اتصال دستی با آدرس سایت و کلیدهای ووکامرس
  Future<bool> connectWithCredentials({
    required String siteUrl,
    required String consumerKey,
    required String consumerSecret,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _dioClient.configureAuth(
        siteUrl: siteUrl,
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
      );

      final result = await _apiService.testConnection();
      _storeName = result['store_name'] ?? 'فروشگاه من';
      _currencySymbol = result['currency_symbol'] ?? 'تومان';
      _siteUrl = siteUrl;

      await _storageService.saveStoreCredentials(
        siteUrl: siteUrl,
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        storeName: _storeName,
        currencySymbol: _currencySymbol,
      );

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// اتصال سریع با اسکن کد QR تولیدشده در پلاگین وردپرس
  Future<bool> connectWithQrPayload(String rawQrData) async {
    try {
      String payload = rawQrData.trim();
      if (payload.startsWith('WOO_APP:')) {
        payload = payload.replaceFirst('WOO_APP:', '');
      }

      final decodedString = utf8.decode(base64Decode(payload));
      final Map<String, dynamic> data = jsonDecode(decodedString);

      final String? url = data['site_url'];
      final String? key = data['consumer_key'];
      final String? secret = data['consumer_secret'];

      if (url == null || key == null || secret == null) {
        throw Exception('اطلاعات کد QR نامعتبر است.');
      }

      return await connectWithCredentials(
        siteUrl: url,
        consumerKey: key,
        consumerSecret: secret,
      );
    } catch (e) {
      _errorMessage = 'خطا در خواندن کد QR: $e';
      notifyListeners();
      return false;
    }
  }

  /// خروج از حساب و لغو اتصال
  Future<void> logout() async {
    await _storageService.clearAll();
    _status = AuthStatus.unauthenticated;
    _siteUrl = '';
    _storeName = 'فروشگاه ووکامرس';
    notifyListeners();
  }

  void setBiometricEnabled(bool enabled) {
    _biometricEnabled = enabled;
    notifyListeners();
  }
}
