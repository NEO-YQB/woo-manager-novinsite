import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/price_formatter.dart';
import '../data/models/notification_model.dart';
import '../data/models/order_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  SharedPreferences? _prefs;

  List<AppNotificationModel> _notifications = [];
  bool _notificationsEnabled = true;
  int _lastSeenOrderId = 0;

  static const String _keyNotificationsList = 'pref_notifications_list';
  static const String _keyNotificationsEnabled = 'pref_notifications_enabled';
  static const String _keyLastSeenOrderId = 'pref_last_seen_order_id';

  List<AppNotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = _prefs?.getBool(_keyNotificationsEnabled) ?? true;
    _lastSeenOrderId = _prefs?.getInt(_keyLastSeenOrderId) ?? 0;

    // بارگذاری لیست نوتیفیکیشن‌های ذخیره شده
    final rawList = _prefs?.getStringList(_keyNotificationsList) ?? [];
    _notifications = rawList
        .map((str) => AppNotificationModel.fromJson(jsonDecode(str)))
        .toList();

    // مرتب‌سازی بر اساس زمان (جدیدترین در ابتدا)
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  /// بررسی سفارشات جدید و ارسال پوش‌نوتیفیکیشن خودکار
  Future<void> checkNewOrders(List<OrderModel> orders) async {
    if (orders.isEmpty) return;

    // پیدا کردن بالاترین شناسه سفارش در سفارشات اخیر
    final currentMaxId = orders.map((o) => o.id).reduce((a, b) => a > b ? a : b);

    // اگر اولین بار است که برنامه لود می‌شود، شناسه ذخیره شده را ست می‌کنیم
    if (_lastSeenOrderId == 0) {
      _lastSeenOrderId = currentMaxId;
      await _prefs?.setInt(_keyLastSeenOrderId, currentMaxId);
      return;
    }

    // اگر سفارش جدیدتری نسبت به آخرین بررسی ثبت شده باشد
    if (currentMaxId > _lastSeenOrderId) {
      final newOrders = orders.where((o) => o.id > _lastSeenOrderId).toList();

      for (var order in newOrders) {
        if (_notificationsEnabled) {
          // ارسال نوتیفیکیشن سیستم اندروید
          await _notificationService.showOrderSuccessNotification(
            orderId: order.id,
            orderNumber: order.number,
            customerName: order.customerFullName,
            total: order.total,
            currencySymbol: order.currencySymbol,
          );
        }

        // افزودن به تاریخچه درون‌برنامه‌ای اعلان‌ها
        final notif = AppNotificationModel(
          id: 'order_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: '🎉 ثبت موفق سفارش #${PriceFormatter.toPersianDigits(order.number)}',
          body: 'خریدار: ${order.customerFullName}  •  مبلغ: ${PriceFormatter.format(order.total, currencySymbol: order.currencySymbol)}',
          orderId: order.id,
          timestamp: DateTime.now(),
          isRead: false,
          type: 'order_new',
        );

        _notifications.insert(0, notif);
      }

      _lastSeenOrderId = currentMaxId;
      await _prefs?.setInt(_keyLastSeenOrderId, currentMaxId);
      await _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  /// ارسال اعلان تستی برای بررسی صحت عملکرد نوتیفیکیشن
  Future<void> triggerTestNotification() async {
    final testId = DateTime.now().millisecondsSinceEpoch % 100000;
    await _notificationService.showGenericNotification(
      id: testId,
      title: '🔔 اعلان آزمایشی فروشگاه',
      body: 'سیستم اعلان‌ها و پوش‌نوتیفیکیشن اپلیکیشن با موفقیت فعال و متصل است.',
    );

    final notif = AppNotificationModel(
      id: 'test_$testId',
      title: '🔔 اعلان آزمایشی فروشگاه',
      body: 'سیستم اعلان‌ها و پوش‌نوتیفیکیشن اپلیکیشن با موفقیت فعال و متصل است.',
      timestamp: DateTime.now(),
      isRead: false,
      type: 'test',
    );

    _notifications.insert(0, notif);
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      await _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotificationsToStorage();
    notifyListeners();
  }

  /// همگام‌سازی اعلان‌های ثبت‌شده در افزونه اختصاصی وردپرس
  Future<void> syncRemoteNotifications(ApiService apiService) async {
    try {
      final remoteList = await apiService.getRecentNotifications();
      if (remoteList.isEmpty) return;

      bool hasNew = false;
      for (var item in remoteList) {
        final orderId = int.tryParse(item['order_id']?.toString() ?? '');
        final notifId = item['id']?.toString() ?? 'order_$orderId';

        if (!_notifications.any((n) => n.id == notifId)) {
          final orderNumber = item['order_number']?.toString() ?? '';
          final customerName = item['customer_name']?.toString() ?? 'مشتری';
          final total = double.tryParse(item['total']?.toString() ?? '0') ?? 0;
          final currency = item['currency_symbol']?.toString() ?? 'تومان';

          final notif = AppNotificationModel(
            id: notifId,
            title: '🎉 ثبت موفق سفارش #${PriceFormatter.toPersianDigits(orderNumber)}',
            body: 'خریدار: $customerName  •  مبلغ: ${PriceFormatter.format(total, currencySymbol: currency)}',
            orderId: orderId,
            timestamp: item['timestamp'] != null
                ? DateTime.tryParse(item['timestamp'].toString()) ?? DateTime.now()
                : DateTime.now(),
            isRead: false,
            type: 'order_new',
          );

          _notifications.insert(0, notif);
          hasNew = true;

          if (_notificationsEnabled && orderId != null) {
            await _notificationService.showOrderSuccessNotification(
              orderId: orderId,
              orderNumber: orderNumber,
              customerName: customerName,
              total: total,
              currencySymbol: currency,
            );
          }
        }
      }

      if (hasNew) {
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        await _saveNotificationsToStorage();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveNotificationsToStorage() async {
    final serialized = _notifications.map((n) => jsonEncode(n.toJson())).toList();
    await _prefs?.setStringList(_keyNotificationsList, serialized);
  }
}
