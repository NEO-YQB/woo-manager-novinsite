import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  /// برقراری تماس تلفنی مستقیم
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final clean = _cleanPhoneNumber(phoneNumber);
    if (clean.isEmpty) return false;

    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// ارسال پیامک
  static Future<bool> sendSms(String phoneNumber, {String? message}) async {
    final clean = _cleanPhoneNumber(phoneNumber);
    if (clean.isEmpty) return false;

    final uri = Uri(
      scheme: 'sms',
      path: clean,
      queryParameters: message != null ? {'body': message} : null,
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// باز کردن چت واتساپ با پیام پیش‌فرض
  static Future<bool> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    var clean = _cleanPhoneNumber(phoneNumber);
    if (clean.isEmpty) return false;

    // تبدیل شماره ایرانی به فرمت بین‌المللی (مثلاً 0912 -> 98912)
    if (clean.startsWith('0')) {
      clean = '98${clean.substring(1)}';
    } else if (clean.startsWith('+')) {
      clean = clean.substring(1);
    }

    final query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    final url = 'https://wa.me/$clean$query';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// قالب پیام آماده برای سفارش مشتری
  static String generateOrderMessageTemplate({
    required String customerName,
    required String orderNumber,
    required String storeName,
    required String statusFa,
  }) {
    return 'سلام $customerName عزیز،\n'
        'از خرید شما در فروشگاه $storeName متشکریم.\n'
        'سفارش شماره #$orderNumber شما در وضعیت «$statusFa» قرار دارد.\n'
        'در صورت داشتن هرگونه سوال در خدمت شما هستیم.';
  }

  static String _cleanPhoneNumber(String input) {
    return input.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  }
}
