import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/utils/price_formatter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _channelId = 'woo_orders_channel';
  static const String _channelName = 'سفارشات جدید ووکامرس';
  static const String _channelDescription =
      'اعلان فوری هنگام ثبت موفق سفارش جدید در فروشگاه وردپرس';

  Future<void> initialize({void Function(NotificationResponse)? onSelect}) async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onSelect,
    );

    await _createNotificationChannel();
    await requestPermissions();
    _isInitialized = true;
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// نمایش نوتیفیکیشن ثبت موفق سفارش جدید
  Future<void> showOrderSuccessNotification({
    required int orderId,
    required String orderNumber,
    required String customerName,
    required double total,
    required String currencySymbol,
  }) async {
    final title = '🎉 سفارش جدید ثبت شد! (#${PriceFormatter.toPersianDigits(orderNumber)})';
    final formattedPrice = PriceFormatter.format(total, currencySymbol: currencySymbol);
    final body = '$customerName یک سفارش به مبلغ $formattedPrice با موفقیت ثبت کرد.';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      orderId,
      title,
      body,
      notificationDetails,
      payload: orderId.toString(),
    );
  }

  /// نمایش نوتیفیکیشن عمومی یا آزمایشی
  Future<void> showGenericNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
