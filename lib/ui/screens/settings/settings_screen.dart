import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../notifications/notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showInvoiceSettingsDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final nameController = TextEditingController(text: settings.sellerName);
    final phoneController = TextEditingController(text: settings.sellerPhone);
    final addressController = TextEditingController(text: settings.sellerAddress);
    final noteController = TextEditingController(text: settings.footerNote);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تنظیمات فاکتور رسمی PDF'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'نام فروشگاه در فاکتور',
                  hint: 'مثلاً دیجی‌استور',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: phoneController,
                  label: 'شماره تلفن فروشگاه',
                  hint: '۰۲۱-۱۲۳۴۵۶۷۸',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: addressController,
                  label: 'نشانی فروشگاه',
                  hint: 'تهران، خیابان...',
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: noteController,
                  label: 'متن پانویس فاکتور',
                  hint: 'از خرید شما متشکریم...',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                await settings.saveInvoiceSettings(
                  sellerName: nameController.text.trim(),
                  sellerPhone: phoneController.text.trim(),
                  sellerAddress: addressController.text.trim(),
                  footerNote: noteController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تنظیمات فاکتور با موفقیت ذخیره شد.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('قطع اتصال از فروشگاه'),
          content: const Text('آیا مطمئن هستید که می‌خواهید از حساب این فروشگاه خارج شوید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
              child: const Text('خروج و قطع اتصال'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات اپلیکیشن', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // کارت وضعیت اتصال به فروشگاه
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.storeName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.siteUrl,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  tooltip: 'قطع اتصال',
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // بخش پوسته و ظاهر
          const Text('پوسته و ظاهر', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('حالت پوسته (تم)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    settings.themeMode == ThemeMode.system
                        ? 'هماهنگ با سیستم عامل'
                        : (settings.themeMode == ThemeMode.dark ? 'حالت تیره (Dark)' : 'حالت روشن (Light)'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('سیستم')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('روشن')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('تیره')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setThemeMode(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('زبان برنامه (Language)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    settings.isPersian ? 'فارسی (Persian)' : 'English (انگلیسی)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: DropdownButton<String>(
                    value: settings.locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'fa',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇮🇷 '),
                            Text('فارسی'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇺🇸 '),
                            Text('English'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        settings.setLocale(Locale(val, val == 'fa' ? 'IR' : 'US'));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.calendar_month_outlined),
                  title: const Text('تقویم هجری شمسی', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('نمایش تمامی تاریخ‌های سفارشات با تقویم خورشیدی', style: TextStyle(fontSize: 12)),
                  value: settings.useShamsiDate,
                  onChanged: (val) => settings.setUseShamsiDate(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.pin_outlined),
                  title: const Text('نمایش ارقام فارسی', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('تبدیل اعداد مبالغ و تاریخ به فونت فارسی', style: TextStyle(fontSize: 12)),
                  value: settings.usePersianDigits,
                  onChanged: (val) => settings.setUsePersianDigits(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // بخش اعلان‌ها و نوتیفیکیشن‌ها
          const Text('اعلان‌ها و نوتیفیکیشن‌ها', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                Consumer<NotificationProvider>(
                  builder: (context, notifProvider, child) {
                    final unread = notifProvider.unreadCount;
                    return ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('مرکز اعلان‌ها', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        unread > 0 ? '$unread اعلان خوانده‌نشده' : 'مشاهده تاریخچه پیام‌ها و اعلان‌های ثبت سفارش',
                        style: TextStyle(
                          fontSize: 12,
                          color: unread > 0 ? AppColors.primary : null,
                          fontWeight: unread > 0 ? FontWeight.w700 : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unread > 0)
                            Badge.count(
                              count: unread,
                              backgroundColor: AppColors.danger,
                            ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_left_rounded),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                Consumer<NotificationProvider>(
                  builder: (context, notifProvider, child) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('پوش‌نوتیفیکیشن سفارشات جدید', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('ارسال نوتیفیکیشن سیستم هنگام ثبت موفق سفارش جدید در سایت', style: TextStyle(fontSize: 12)),
                      value: notifProvider.notificationsEnabled,
                      onChanged: (val) => notifProvider.setNotificationsEnabled(val),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // امنیت و قفل برنامه
          const Text('امنیت', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.fingerprint_rounded),
              title: const Text('قفل بیومتریک (اثر انگشت / چهره)', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('درخواست اثر انگشت به هنگام ورود به اپلیکیشن', style: TextStyle(fontSize: 12)),
              value: settings.biometricEnabled,
              onChanged: (val) {
                settings.setBiometricEnabled(val);
                authProvider.setBiometricEnabled(val);
              },
            ),
          ),

          const SizedBox(height: 20),

          // تنظیمات فاکتور رسمی
          const Text('فاکتور و چاپ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: const Text('تنظیمات فاکتور رسمی PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('ویرایش نام فروشگاه، شماره تماس، نشانی و متن پانویس فاکتور', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => _showInvoiceSettingsDialog(context),
            ),
          ),

          const SizedBox(height: 20),

          // راهنمای پلاگین وردپرس
          const Text('پلاگین کمکی وردپرس', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.extension_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('افزونه اختصاصی Woo Mobile Connector', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'این افزونه در پوشه `wordpress-plugin/woo-mobile-connector` داخل پروژه قرار دارد. برای اتصال با کد QR و افزایش سرعت تا ۵ برابر، آن را در وردپرس نصب کنید.',
                    style: TextStyle(fontSize: 12, height: 1.6, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // هویت بصری و برندینگ نوین سایت
          Center(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نسخه ${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(AppConstants.developerUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'ساخته شده با 💚 توسط ',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'نوین سایت',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
