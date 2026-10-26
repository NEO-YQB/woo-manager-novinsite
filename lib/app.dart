import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/screens/auth/connect_screen.dart';
import 'ui/screens/main_screen.dart';

class WooStoreApp extends StatelessWidget {
  const WooStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // پشتیبانی کامل از دو زبان فارسی (RTL) و انگلیسی (LTR)
      locale: settings.locale,
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          switch (auth.status) {
            case AuthStatus.authenticated:
              return const MainScreen();
            case AuthStatus.biometricRequired:
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint_rounded, size: 72, color: Colors.indigo),
                      const SizedBox(height: 16),
                      const Text(
                        'قفل امنیتی فعال است',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text('جهت ورود به پنل، اثر انگشت خود را تأیید کنید'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => auth.authenticateWithBiometrics(),
                        child: const Text('تأیید اثر انگشت'),
                      ),
                    ],
                  ),
                ),
              );
            case AuthStatus.unknown:
            case AuthStatus.authenticating:
            case AuthStatus.unauthenticated:
            default:
              return const ConnectScreen();
          }
        },
      ),
    );
  }
}
