import 'package:flutter_test/flutter_test.dart';
import 'package:woo_store_manager/core/constants/app_colors.dart';
import 'package:woo_store_manager/core/utils/price_formatter.dart';
import 'package:woo_store_manager/core/utils/date_formatter.dart';
import 'package:woo_store_manager/data/models/order_model.dart';
import 'package:woo_store_manager/data/models/product_model.dart';
import 'package:woo_store_manager/data/models/dashboard_stats_model.dart';
import 'package:woo_store_manager/data/models/notification_model.dart';

void main() {
  group('PriceFormatter Tests', () {
    test('Format numbers to Persian digits correctly', () {
      final fa = PriceFormatter.toPersianDigits('1234567890');
      expect(fa, '۱۲۳۴۵۶۷۸۹۰');
    });

    test('Format amount with comma separation and currency', () {
      final formatted = PriceFormatter.format(1500000, currencySymbol: 'تومان');
      expect(formatted, contains('۱,۵۰۰,۰۰۰'));
      expect(formatted, contains('تومان'));
    });

    test('Format zero amount returns free', () {
      final formatted = PriceFormatter.format(0, showCurrency: true);
      expect(formatted, 'رایگان');
    });
  });

  group('DateFormatter Tests', () {
    test('Format ISO string to Jalali Shamsi date', () {
      final dt = DateTime(2026, 3, 21, 14, 30);
      final faDate = DateFormatter.format(dt, useShamsi: true, includeTime: false);
      expect(faDate, isNotEmpty);
      expect(faDate, contains('۱۴۰۵')); // 2026 is 1405 in Jalali
    });
  });

  group('AppColors & Status Tests', () {
    test('Status Persian titles mapping', () {
      expect(AppColors.getStatusTitleFa('processing'), 'در حال انجام');
      expect(AppColors.getStatusTitleFa('completed'), 'تکمیل شده');
      expect(AppColors.getStatusTitleFa('pending'), 'در انتظار پرداخت');
      expect(AppColors.getStatusTitleFa('cancelled'), 'لغو شده');
    });
  });

  group('Models JSON Parsing Tests', () {
    test('OrderModel parses from WooCommerce JSON', () {
      final sampleJson = {
        'id': 105,
        'number': '105',
        'status': 'processing',
        'date_created': '2026-10-25T10:00:00',
        'total': '450000',
        'currency': 'IRT',
        'currency_symbol': 'تومان',
        'billing': {
          'first_name': 'رضا',
          'last_name': 'محمدی',
          'phone': '09123456789',
          'city': 'تهران',
          'address_1': 'خیابان آزادی',
        },
        'line_items': [
          {
            'id': 1,
            'name': 'کفش ورزشی',
            'product_id': 20,
            'quantity': 2,
            'price': '225000',
            'total': '450000',
          }
        ]
      };

      final order = OrderModel.fromJson(sampleJson);
      expect(order.id, 105);
      expect(order.customerFullName, 'رضا محمدی');
      expect(order.total, 450000);
      expect(order.lineItems.length, 1);
      expect(order.lineItems.first.quantity, 2);
    });

    test('ProductModel parses from WooCommerce JSON', () {
      final sampleJson = {
        'id': 42,
        'name': 'هدفون بی‌سیم',
        'regular_price': '1200000',
        'sale_price': '950000',
        'on_sale': true,
        'stock_quantity': 15,
        'manage_stock': true,
        'stock_status': 'instock',
        'status': 'publish',
        'images': [
          {'id': 1, 'src': 'https://example.com/p.jpg', 'name': 'img', 'alt': ''}
        ],
      };

      final product = ProductModel.fromJson(sampleJson);
      expect(product.id, 42);
      expect(product.name, 'هدفون بی‌سیم');
      expect(product.regularPrice, 1200000);
      expect(product.salePrice, 950000);
      expect(product.onSale, true);
      expect(product.isInStock, true);
      expect(product.mainImageUrl, 'https://example.com/p.jpg');
    });

    test('DashboardStatsModel from plugin JSON', () {
      final samplePluginJson = {
        'success': true,
        'store': {
          'name': 'فروشگاه تستی',
          'url': 'https://test.com',
          'currency': 'IRT',
          'currency_symbol': 'تومان',
        },
        'kpis': {
          'today_sales': 2500000,
          'today_orders_count': 5,
          'pending_orders': 2,
          'processing_orders': 4,
          'completed_orders': 18,
          'low_stock_count': 3,
          'out_of_stock_count': 1,
        },
        'recent_orders': [],
        'weekly_sales': [
          {'day': 'ش', 'date': '2026-10-20', 'revenue': 450000, 'orders_count': 2},
          {'day': 'ی', 'date': '2026-10-21', 'revenue': 800000, 'orders_count': 3},
        ],
      };

      final stats = DashboardStatsModel.fromPluginJson(samplePluginJson);
      expect(stats.storeName, 'فروشگاه تستی');
      expect(stats.todaySales, 2500000);
      expect(stats.todayOrdersCount, 5);
      expect(stats.processingOrders, 4);
      expect(stats.lowStockCount, 3);
      expect(stats.weeklySales.length, 2);
      expect(stats.weeklySales.first.day, 'ش');
      expect(stats.weeklySales.first.ordersCount, 2);
    });

    test('AppNotificationModel serialization and deserialization', () {
      final notif = AppNotificationModel(
        id: 'notif_100',
        title: 'ثبت سفارش جدید',
        body: 'سفارش شماره #100 با موفقیت ثبت شد',
        orderId: 100,
        timestamp: DateTime(2026, 10, 26, 14, 0),
        isRead: false,
        type: 'order_new',
      );

      final json = notif.toJson();
      expect(json['id'], 'notif_100');
      expect(json['orderId'], 100);

      final reconstructed = AppNotificationModel.fromJson(json);
      expect(reconstructed.id, notif.id);
      expect(reconstructed.title, notif.title);
      expect(reconstructed.orderId, 100);
      expect(reconstructed.isRead, false);
    });
  });
}
