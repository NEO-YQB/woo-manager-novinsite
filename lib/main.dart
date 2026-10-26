import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/security/biometric_service.dart';
import 'core/security/secure_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // راه‌اندازی سرویس‌های پایه
  final storageService = SecureStorageService();
  final biometricService = BiometricService();
  final dioClient = DioClient();

  // راه‌اندازی سرویس اعلان‌ها و نوتیفیکیشن سیستم
  final notificationService = NotificationService();
  await notificationService.initialize();

  final notificationProvider = NotificationProvider();
  await notificationProvider.init();

  // ارائه‌دهنده تنظیمات
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  // ارائه‌دهنده احراز هویت
  final authProvider = AuthProvider(
    storageService: storageService,
    biometricService: biometricService,
    dioClient: dioClient,
  );

  // بررسی وضعیت ورود قبلی
  await authProvider.checkAuthStatus(
    requireBiometrics: settingsProvider.biometricEnabled,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (context) => DashboardProvider(authProvider.apiService),
          update: (context, auth, prev) => prev ?? DashboardProvider(auth.apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (context) => OrdersProvider(authProvider.apiService),
          update: (context, auth, prev) => prev ?? OrdersProvider(auth.apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (context) => ProductsProvider(authProvider.apiService),
          update: (context, auth, prev) => prev ?? ProductsProvider(auth.apiService),
        ),
      ],
      child: const WooStoreApp(),
    ),
  );
}
