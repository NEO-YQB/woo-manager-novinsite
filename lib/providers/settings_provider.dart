import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('fa', 'IR');
  bool _biometricEnabled = false;
  bool _usePersianDigits = true;
  bool _useShamsiDate = true;
  String _sellerName = '';
  String _sellerPhone = '';
  String _sellerAddress = '';
  String _footerNote = 'از خرید و اعتماد شما سپاسگزاریم.';

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isPersian => _locale.languageCode == 'fa';
  bool get biometricEnabled => _biometricEnabled;
  bool get usePersianDigits => _usePersianDigits;
  bool get useShamsiDate => _useShamsiDate;
  String get sellerName => _sellerName;
  String get sellerPhone => _sellerPhone;
  String get sellerAddress => _sellerAddress;
  String get footerNote => _footerNote;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final themeStr = _prefs?.getString(AppConstants.prefThemeMode);
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    final langStr = _prefs?.getString(AppConstants.prefLanguage);
    if (langStr == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('fa', 'IR');
    }

    _biometricEnabled = _prefs?.getBool(AppConstants.prefBiometricEnabled) ?? false;
    _usePersianDigits = _prefs?.getBool(AppConstants.prefUsePersianDigits) ?? true;
    _useShamsiDate = _prefs?.getBool(AppConstants.prefUseShamsiDate) ?? true;
    _sellerName = _prefs?.getString(AppConstants.prefInvoiceSellerName) ?? '';
    _sellerPhone = _prefs?.getString(AppConstants.prefInvoicePhone) ?? '';
    _sellerAddress = _prefs?.getString(AppConstants.prefInvoiceAddress) ?? '';
    _footerNote = _prefs?.getString(AppConstants.prefInvoiceFooterNote) ?? 'از خرید و اعتماد شما سپاسگزاریم.';

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _prefs?.setString(AppConstants.prefThemeMode, val);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    if (locale.languageCode == 'en') {
      _usePersianDigits = false;
      _useShamsiDate = false;
      await _prefs?.setBool(AppConstants.prefUsePersianDigits, false);
      await _prefs?.setBool(AppConstants.prefUseShamsiDate, false);
    } else {
      _usePersianDigits = true;
      _useShamsiDate = true;
      await _prefs?.setBool(AppConstants.prefUsePersianDigits, true);
      await _prefs?.setBool(AppConstants.prefUseShamsiDate, true);
    }
    await _prefs?.setString(AppConstants.prefLanguage, locale.languageCode);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    notifyListeners();
    await _prefs?.setBool(AppConstants.prefBiometricEnabled, enabled);
  }

  Future<void> setUsePersianDigits(bool enabled) async {
    _usePersianDigits = enabled;
    notifyListeners();
    await _prefs?.setBool(AppConstants.prefUsePersianDigits, enabled);
  }

  Future<void> setUseShamsiDate(bool enabled) async {
    _useShamsiDate = enabled;
    notifyListeners();
    await _prefs?.setBool(AppConstants.prefUseShamsiDate, enabled);
  }

  Future<void> saveInvoiceSettings({
    required String sellerName,
    required String sellerPhone,
    required String sellerAddress,
    required String footerNote,
  }) async {
    _sellerName = sellerName;
    _sellerPhone = sellerPhone;
    _sellerAddress = sellerAddress;
    _footerNote = footerNote;
    notifyListeners();

    await _prefs?.setString(AppConstants.prefInvoiceSellerName, sellerName);
    await _prefs?.setString(AppConstants.prefInvoicePhone, sellerPhone);
    await _prefs?.setString(AppConstants.prefInvoiceAddress, sellerAddress);
    await _prefs?.setString(AppConstants.prefInvoiceFooterNote, footerNote);
  }
}
