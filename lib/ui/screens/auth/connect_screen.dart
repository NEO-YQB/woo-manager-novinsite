import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import 'qr_scanner_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  final _secretController = TextEditingController();
  bool _obscureSecret = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _keyController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _handleManualConnect() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.connectWithCredentials(
      siteUrl: _urlController.text.trim(),
      consumerKey: _keyController.text.trim(),
      consumerSecret: _secretController.text.trim(),
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اتصال به فروشگاه با موفقیت برقرار شد.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleScanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (result != null && mounted) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.connectWithQrPayload(result);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فروشگاه شما با موفقیت متصل شد.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // لوگو و هدر برند
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'مدیریت فروشگاه نوین سایت',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سایت وردپرسی خود را برای مدیریت سفارشات و محصولات متصل کنید',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // تب انتخاب شیوه اتصال
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Vazirmatn'),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.qr_code_scanner_rounded, size: 20),
                      text: 'اسکن سریع QR',
                    ),
                    Tab(
                      icon: Icon(Icons.key_rounded, size: 20),
                      text: 'اتصال با کلید API',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // پیام خطا در صورت وجود
              if (authProvider.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // محتوای تب‌ها
              SizedBox(
                height: 360,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // تب اول: اسکن کد QR
                    _buildQrTab(isDark, authProvider.status == AuthStatus.authenticating),

                    // تب دوم: اتصال دستی
                    _buildManualTab(authProvider.status == AuthStatus.authenticating),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // پانویس برندینگ و توسعه‌دهنده نوین سایت
              Center(
                child: InkWell(
                  onTap: () async {
                    final uri = Uri.parse(AppConstants.developerUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'ساخته شده با 💚 توسط ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
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
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrTab(bool isDark, bool isLoading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 54, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'سریع‌ترین و امن‌ترین شیوه ورود',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'پلاگین کمکی وردپرس را در سایت خود فعال کرده و کد QR نمایش داده شده در پیشخوان وردپرس را اسکن کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleScanQr,
            icon: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.camera_alt_rounded),
            label: Text(
              isLoading ? 'در حال بررسی اتصال...' : 'اسکن کد QR با دوربین',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _urlController,
            label: 'آدرس فروشگاه (Site URL)',
            hint: 'https://example.com',
            prefixIcon: Icons.link_rounded,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.url,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'لطفاً آدرس سایت را وارد کنید';
              if (!val.startsWith('http://') && !val.startsWith('https://')) {
                return 'آدرس باید با https:// یا http:// شروع شود';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _keyController,
            label: 'کلید مصرف‌کننده (Consumer Key)',
            hint: 'ck_xxxxxxxxxxxxxxxxxxxxxxxx',
            prefixIcon: Icons.key_outlined,
            textDirection: TextDirection.ltr,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'کلید مصرف‌کننده الزامی است';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _secretController,
            label: 'رمز مصرف‌کننده (Consumer Secret)',
            hint: 'cs_xxxxxxxxxxxxxxxxxxxxxxxx',
            prefixIcon: Icons.lock_outline_rounded,
            textDirection: TextDirection.ltr,
            obscureText: _obscureSecret,
            suffixIcon: IconButton(
              icon: Icon(_obscureSecret ? Icons.visibility_off : Icons.visibility, size: 20),
              onPressed: () => setState(() => _obscureSecret = !_obscureSecret),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'رمز مصرف‌کننده الزامی است';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleManualConnect,
              child: isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('بررسی و ورود به اپلیکیشن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
