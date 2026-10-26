import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// کلاس جامع بومی‌سازی دو زبانه (فارسی و انگلیسی) برای اپلیکیشن مدیریت فروشگاه نوین سایت
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('fa', 'IR'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  bool get isPersian => locale.languageCode == 'fa';

  static final Map<String, Map<String, String>> _localizedValues = {
    'fa': {
      // General & Branding
      'appName': 'مدیریت فروشگاه نوین سایت',
      'developerBranding': 'ساخته شده با 💚 توسط نوین سایت',
      'version': 'نسخه',
      'cancel': 'انصراف',
      'save': 'ذخیره',
      'confirm': 'تأیید',
      'delete': 'حذف',
      'search': 'جستجو...',
      'filter': 'فیلتر',
      'refresh': 'بروزرسانی',
      'retry': 'تلاش مجدد',
      'error': 'خطا در بارگذاری',
      'success': 'عملیات با موفقیت انجام شد',
      'connected': 'متصل به فروشگاه',
      'disconnected': 'قطع اتصال',

      // Navigation
      'navDashboard': 'داشبورد',
      'navOrders': 'سفارشات',
      'navProducts': 'محصولات',
      'navCustomers': 'مشتریان',
      'navSettings': 'تنظیمات',

      // Dashboard
      'dashboardTitle': 'داشبورد فروشگاه',
      'todaySales': 'فروش امروز',
      'monthSales': 'فروش این ماه',
      'processingOrders': 'سفارشات جاری',
      'pendingPayment': 'در انتظار پرداخت',
      'lowStock': 'کالای رو به اتمام',
      'outOfStock': 'کالای ناموجود',
      'weeklySalesChart': 'روند فروش ۷ روز گذشته',
      'recentOrders': 'جدیدترین سفارش‌ها',
      'viewAll': 'مشاهده همه',
      'noOrders': 'سفارشی یافت نشد',
      'orderNumber': 'سفارش شماره',

      // Orders
      'ordersTitle': 'مدیریت سفارشات',
      'searchOrderHint': 'شماره سفارش، نام مشتری، موبایل...',
      'allStatuses': 'همه',
      'statusPending': 'در انتظار پرداخت',
      'statusProcessing': 'در حال انجام',
      'statusOnHold': 'در انتظار بررسی',
      'statusCompleted': 'تکمیل شده',
      'statusCancelled': 'لغو شده',
      'statusRefunded': 'مسترد شده',
      'statusFailed': 'ناموفق',
      'changeStatus': 'تغییر وضعیت سفارش',
      'printInvoice': 'چاپ و صدور فاکتور',
      'orderItems': 'اقلام سفارش',
      'customerNotes': 'یادداشت‌های سفارش',
      'addNote': 'افزودن یادداشت جدید',
      'callCustomer': 'تماس تلفنی',
      'whatsapp': 'پیام واتساپ',
      'sms': 'ارسال پیامک',

      // Products
      'productsTitle': 'مدیریت محصولات',
      'searchProductHint': 'نام محصول، کد کالا (SKU)...',
      'quickEdit': 'ویرایش سریع',
      'regularPrice': 'قیمت عادی',
      'salePrice': 'قیمت فروش ویژه',
      'stockQuantity': 'موجودی انبار',
      'inStock': 'موجود در انبار',
      'outOfStockStatus': 'ناموجود',
      'addProduct': 'افزودن محصول جدید',

      // Customers
      'customersTitle': 'مشتریان فروشگاه',
      'searchCustomerHint': 'نام، ایمیل، شماره تماس...',
      'totalOrders': 'تعداد سفارشات',
      'totalSpent': 'مجموع خرید',

      // Notifications
      'notificationsTitle': 'مرکز اعلان‌ها',
      'noNotifications': 'هیچ اعلانی ثبت نشده است',
      'clearNotifications': 'پاکسازی همه اعلان‌ها',
      'testNotification': 'ارسال تست اعلان',

      // Settings
      'settingsTitle': 'تنظیمات برنامه',
      'appearance': 'ظاهر و پوسته',
      'themeMode': 'حالت پوسته',
      'themeLight': 'روشن',
      'themeDark': 'تاریک',
      'themeSystem': 'هماهنگ با سیستم',
      'language': 'زبان برنامه (Language)',
      'langPersian': 'فارسی (Persian)',
      'langEnglish': 'انگلیسی (English)',
      'calendar': 'نوع تقویم',
      'calendarShamsi': 'شمسی (خورشیدی)',
      'calendarGregorian': 'میلادی (Gregorian)',
      'digits': 'فرمت ارقام',
      'digitsPersian': 'ارقام فارسی (۱۲۳)',
      'digitsEnglish': 'ارقام انگلیسی (123)',
      'security': 'امنیت',
      'biometricLock': 'قفل بیومتریک (اثر انگشت / چهره)',
      'invoiceSettings': 'تنظیمات فاکتور رسمی PDF',
      'pluginHelp': 'افزونه کمکی وردپرس',
      'logout': 'خروج از حساب فروشگاه',
      'logoutConfirm': 'آیا مطمئن هستید که می‌خواهید از حساب این فروشگاه خارج شوید؟',

      // Auth & Connect
      'connectTitle': 'اتصال به فروشگاه',
      'scanQr': 'اسکن سریع کد QR',
      'manualConnect': 'ورود با کلید API',
      'siteUrl': 'آدرس فروشگاه (Site URL)',
      'consumerKey': 'کلید مصرف‌کننده (Consumer Key)',
      'consumerSecret': 'رمز مصرف‌کننده (Consumer Secret)',
      'connectButton': 'بررسی و ورود به اپلیکیشن',
      'scanQrButton': 'اسکن کد QR با دوربین',
    },
    'en': {
      // General & Branding
      'appName': 'NovinSite Store Manager',
      'developerBranding': 'Built with 💚 by NovinSite',
      'version': 'Version',
      'cancel': 'Cancel',
      'save': 'Save',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'search': 'Search...',
      'filter': 'Filter',
      'refresh': 'Refresh',
      'retry': 'Retry',
      'error': 'Loading Error',
      'success': 'Action completed successfully',
      'connected': 'Connected to Store',
      'disconnected': 'Disconnected',

      // Navigation
      'navDashboard': 'Dashboard',
      'navOrders': 'Orders',
      'navProducts': 'Products',
      'navCustomers': 'Customers',
      'navSettings': 'Settings',

      // Dashboard
      'dashboardTitle': 'Store Dashboard',
      'todaySales': "Today's Sales",
      'monthSales': 'Monthly Sales',
      'processingOrders': 'Processing Orders',
      'pendingPayment': 'Pending Payment',
      'lowStock': 'Low Stock Items',
      'outOfStock': 'Out of Stock Items',
      'weeklySalesChart': 'Last 7 Days Sales Trend',
      'recentOrders': 'Recent Orders',
      'viewAll': 'View All',
      'noOrders': 'No orders found',
      'orderNumber': 'Order #',

      // Orders
      'ordersTitle': 'Orders Management',
      'searchOrderHint': 'Order #, customer name, phone...',
      'allStatuses': 'All',
      'statusPending': 'Pending Payment',
      'statusProcessing': 'Processing',
      'statusOnHold': 'On Hold',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',
      'statusRefunded': 'Refunded',
      'statusFailed': 'Failed',
      'changeStatus': 'Change Order Status',
      'printInvoice': 'Print & Export Invoice',
      'orderItems': 'Order Items',
      'customerNotes': 'Order Notes',
      'addNote': 'Add New Note',
      'callCustomer': 'Call Customer',
      'whatsapp': 'WhatsApp Message',
      'sms': 'Send SMS',

      // Products
      'productsTitle': 'Products Management',
      'searchProductHint': 'Product title, SKU...',
      'quickEdit': 'Quick Edit',
      'regularPrice': 'Regular Price',
      'salePrice': 'Sale Price',
      'stockQuantity': 'Stock Quantity',
      'inStock': 'In Stock',
      'outOfStockStatus': 'Out of Stock',
      'addProduct': 'Add New Product',

      // Customers
      'customersTitle': 'Store Customers',
      'searchCustomerHint': 'Name, email, phone...',
      'totalOrders': 'Total Orders',
      'totalSpent': 'Total Spent',

      // Notifications
      'notificationsTitle': 'Notification Center',
      'noNotifications': 'No notifications yet',
      'clearNotifications': 'Clear All Notifications',
      'testNotification': 'Send Test Notification',

      // Settings
      'settingsTitle': 'App Settings',
      'appearance': 'Appearance & Theme',
      'themeMode': 'Theme Mode',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System Default',
      'language': 'App Language',
      'langPersian': 'Persian (فارسی)',
      'langEnglish': 'English (انگلیسی)',
      'calendar': 'Calendar Type',
      'calendarShamsi': 'Persian (Solar Hijri)',
      'calendarGregorian': 'Gregorian',
      'digits': 'Number Digits Format',
      'digitsPersian': 'Persian Digits (۱۲۳)',
      'digitsEnglish': 'English Digits (123)',
      'security': 'Security',
      'biometricLock': 'Biometric Lock (Fingerprint / Face)',
      'invoiceSettings': 'Official PDF Invoice Settings',
      'pluginHelp': 'WordPress Companion Plugin',
      'logout': 'Disconnect & Logout',
      'logoutConfirm': 'Are you sure you want to disconnect from this store?',

      // Auth & Connect
      'connectTitle': 'Connect to Store',
      'scanQr': 'Quick QR Scan',
      'manualConnect': 'Manual API Connect',
      'siteUrl': 'Store URL',
      'consumerKey': 'Consumer Key',
      'consumerSecret': 'Consumer Secret',
      'connectButton': 'Verify & Enter App',
      'scanQrButton': 'Scan QR Code with Camera',
    },
  };

  String translate(String key) {
    final lang = locale.languageCode == 'en' ? 'en' : 'fa';
    return _localizedValues[lang]?[key] ?? _localizedValues['fa']?[key] ?? key;
  }

  // Getters for common terms
  String get appName => translate('appName');
  String get developerBranding => translate('developerBranding');
  String get version => translate('version');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get confirm => translate('confirm');
  String get delete => translate('delete');
  String get search => translate('search');
  String get filter => translate('filter');
  String get refresh => translate('refresh');
  String get retry => translate('retry');
  String get error => translate('error');
  String get success => translate('success');
  String get connected => translate('connected');
  String get disconnected => translate('disconnected');

  // Navigation
  String get navDashboard => translate('navDashboard');
  String get navOrders => translate('navOrders');
  String get navProducts => translate('navProducts');
  String get navCustomers => translate('navCustomers');
  String get navSettings => translate('navSettings');

  // Dashboard
  String get dashboardTitle => translate('dashboardTitle');
  String get todaySales => translate('todaySales');
  String get monthSales => translate('monthSales');
  String get processingOrders => translate('processingOrders');
  String get pendingPayment => translate('pendingPayment');
  String get lowStock => translate('lowStock');
  String get outOfStock => translate('outOfStock');
  String get weeklySalesChart => translate('weeklySalesChart');
  String get recentOrders => translate('recentOrders');
  String get viewAll => translate('viewAll');
  String get noOrders => translate('noOrders');
  String get orderNumber => translate('orderNumber');

  // Orders
  String get ordersTitle => translate('ordersTitle');
  String get searchOrderHint => translate('searchOrderHint');
  String get allStatuses => translate('allStatuses');
  String get changeStatus => translate('changeStatus');
  String get printInvoice => translate('printInvoice');
  String get orderItems => translate('orderItems');
  String get customerNotes => translate('customerNotes');
  String get addNote => translate('addNote');
  String get callCustomer => translate('callCustomer');
  String get whatsapp => translate('whatsapp');
  String get sms => translate('sms');

  // Products
  String get productsTitle => translate('productsTitle');
  String get searchProductHint => translate('searchProductHint');
  String get quickEdit => translate('quickEdit');
  String get regularPrice => translate('regularPrice');
  String get salePrice => translate('salePrice');
  String get stockQuantity => translate('stockQuantity');
  String get inStock => translate('inStock');
  String get outOfStockStatus => translate('outOfStockStatus');
  String get addProduct => translate('addProduct');

  // Customers
  String get customersTitle => translate('customersTitle');
  String get searchCustomerHint => translate('searchCustomerHint');
  String get totalOrders => translate('totalOrders');
  String get totalSpent => translate('totalSpent');

  // Notifications
  String get notificationsTitle => translate('notificationsTitle');
  String get noNotifications => translate('noNotifications');
  String get clearNotifications => translate('clearNotifications');
  String get testNotification => translate('testNotification');

  // Settings
  String get settingsTitle => translate('settingsTitle');
  String get appearance => translate('appearance');
  String get themeMode => translate('themeMode');
  String get themeLight => translate('themeLight');
  String get themeDark => translate('themeDark');
  String get themeSystem => translate('themeSystem');
  String get language => translate('language');
  String get langPersian => translate('langPersian');
  String get langEnglish => translate('langEnglish');
  String get calendar => translate('calendar');
  String get calendarShamsi => translate('calendarShamsi');
  String get calendarGregorian => translate('calendarGregorian');
  String get digits => translate('digits');
  String get digitsPersian => translate('digitsPersian');
  String get digitsEnglish => translate('digitsEnglish');
  String get security => translate('security');
  String get biometricLock => translate('biometricLock');
  String get invoiceSettings => translate('invoiceSettings');
  String get pluginHelp => translate('pluginHelp');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logoutConfirm');

  // Auth & Connect
  String get connectTitle => translate('connectTitle');
  String get scanQr => translate('scanQr');
  String get manualConnect => translate('manualConnect');
  String get siteUrl => translate('siteUrl');
  String get consumerKey => translate('consumerKey');
  String get consumerSecret => translate('consumerSecret');
  String get connectButton => translate('connectButton');
  String get scanQrButton => translate('scanQrButton');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fa', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
