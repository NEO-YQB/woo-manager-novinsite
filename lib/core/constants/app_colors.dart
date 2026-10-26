import 'package:flutter/material.dart';

class AppColors {
  // رنگ‌های برند اصلی
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color secondary = Color(0xFF7F54B3); // WooCommerce Purple
  static const Color secondaryLight = Color(0xFFF5F0FF);

  // پس‌زمینه‌های لایت مود
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // پس‌زمینه‌های دارک مود (OLED Friendly)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // رنگ‌های متنی
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // وضعیت‌های سفارشات ووکامرس (WooCommerce Order Status Colors)
  static const Color statusPending = Color(0xFFF59E0B);     // زرد/نارنجی (در انتظار پرداخت)
  static const Color statusProcessing = Color(0xFF3B82F6);  // آبی مدرن (در حال انجام)
  static const Color statusOnHold = Color(0xFF8B5CF6);      // بنفش ملایم (در انتظار بررسی)
  static const Color statusCompleted = Color(0xFF10B981);   // سبز زمردی (تکمیل شده)
  static const Color statusCancelled = Color(0xFFEF4444);   // قرمز شفاف (لغو شده)
  static const Color statusRefunded = Color(0xFF64748B);    // خاکستری (مسترد شده)
  static const Color statusFailed = Color(0xFFDC2626);      // زرشکی (ناموفق)

  // رنگ‌های هشدار و کمبود موجودی
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // گرادیانت‌های جذاب داشبورد
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return statusProcessing;
      case 'completed':
        return statusCompleted;
      case 'on-hold':
        return statusOnHold;
      case 'pending':
        return statusPending;
      case 'cancelled':
        return statusCancelled;
      case 'refunded':
        return statusRefunded;
      case 'failed':
        return statusFailed;
      default:
        return textSecondaryLight;
    }
  }

  static String getStatusTitleFa(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'در حال انجام';
      case 'completed':
        return 'تکمیل شده';
      case 'on-hold':
        return 'در انتظار بررسی';
      case 'pending':
        return 'در انتظار پرداخت';
      case 'cancelled':
        return 'لغو شده';
      case 'refunded':
        return 'مسترد شده';
      case 'failed':
        return 'ناموفق';
      default:
        return status;
    }
  }
}
