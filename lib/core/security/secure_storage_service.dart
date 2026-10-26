import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  Future<void> saveStoreCredentials({
    required String siteUrl,
    required String consumerKey,
    required String consumerSecret,
    String? appToken,
    String? storeName,
    String? currency,
    String? currencySymbol,
  }) async {
    // نرمال‌سازی URL (حذف اسلش انتهایی)
    var cleanUrl = siteUrl.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    await _storage.write(key: AppConstants.keySiteUrl, value: cleanUrl);
    await _storage.write(key: AppConstants.keyConsumerKey, value: consumerKey.trim());
    await _storage.write(key: AppConstants.keyConsumerSecret, value: consumerSecret.trim());

    if (appToken != null) {
      await _storage.write(key: AppConstants.keyAppToken, value: appToken);
    }
    if (storeName != null) {
      await _storage.write(key: AppConstants.keyStoreName, value: storeName);
    }
    if (currency != null) {
      await _storage.write(key: AppConstants.keyCurrency, value: currency);
    }
    if (currencySymbol != null) {
      await _storage.write(key: AppConstants.keyCurrencySymbol, value: currencySymbol);
    }
  }

  Future<String?> getSiteUrl() async {
    return await _storage.read(key: AppConstants.keySiteUrl);
  }

  Future<String?> getConsumerKey() async {
    return await _storage.read(key: AppConstants.keyConsumerKey);
  }

  Future<String?> getConsumerSecret() async {
    return await _storage.read(key: AppConstants.keyConsumerSecret);
  }

  Future<String?> getAppToken() async {
    return await _storage.read(key: AppConstants.keyAppToken);
  }

  Future<String?> getStoreName() async {
    return await _storage.read(key: AppConstants.keyStoreName);
  }

  Future<String?> getCurrencySymbol() async {
    return await _storage.read(key: AppConstants.keyCurrencySymbol);
  }

  Future<bool> hasCredentials() async {
    final url = await getSiteUrl();
    final key = await getConsumerKey();
    final secret = await getConsumerSecret();
    return url != null && url.isNotEmpty && key != null && secret != null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
