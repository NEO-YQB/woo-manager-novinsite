class AppConstants {
  static const String appName = 'مدیریت فروشگاه نوین سایت';
  static const String appVersion = '1.0.0';
  static const String developerName = 'نوین سایت';
  static const String developerUrl = 'https://novinsite.com';
  static const String developerBranding = 'ساخته شده با 💚 توسط نوین سایت';

  // کلیدهای حافظه امن (Secure Storage Keys)
  static const String keySiteUrl = 'secure_site_url';
  static const String keyConsumerKey = 'secure_consumer_key';
  static const String keyConsumerSecret = 'secure_consumer_secret';
  static const String keyAppToken = 'secure_app_token';
  static const String keyStoreName = 'secure_store_name';
  static const String keyCurrency = 'secure_currency';
  static const String keyCurrencySymbol = 'secure_currency_symbol';

  // کلیدهای SharedPreferences
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLanguage = 'pref_language';
  static const String prefBiometricEnabled = 'pref_biometric_enabled';
  static const String prefUsePersianDigits = 'pref_persian_digits';
  static const String prefUseShamsiDate = 'pref_shamsi_date';
  static const String prefInvoiceSellerName = 'pref_invoice_seller_name';
  static const String prefInvoicePhone = 'pref_invoice_phone';
  static const String prefInvoiceAddress = 'pref_invoice_address';
  static const String prefInvoiceFooterNote = 'pref_invoice_footer_note';

  // مسیرهای REST API استاندارد ووکامرس
  static const String wcApiPath = '/wp-json/wc/v3';
  static const String customPluginApiPath = '/wp-json/woo-app/v1';

  // پیش‌فرض‌های اتصال
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}
