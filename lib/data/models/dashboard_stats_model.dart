import 'order_model.dart';

class DailySalesModel {
  final String day;
  final String date;
  final double revenue;
  final int ordersCount;

  DailySalesModel({
    required this.day,
    required this.date,
    required this.revenue,
    required this.ordersCount,
  });

  factory DailySalesModel.fromJson(Map<String, dynamic> json) {
    return DailySalesModel(
      day: json['day']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0,
      ordersCount: int.tryParse(json['orders_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class DashboardStatsModel {
  final double todaySales;
  final int todayOrdersCount;
  final double monthSales;
  final int monthOrdersCount;
  final int pendingOrders;
  final int processingOrders;
  final int onHoldOrders;
  final int completedOrders;
  final int lowStockCount;
  final int outOfStockCount;
  final Map<String, int> orderStatuses;
  final List<OrderModel> recentOrders;
  final List<DailySalesModel> weeklySales;
  final String storeName;
  final String storeUrl;
  final String currency;
  final String currencySymbol;

  DashboardStatsModel({
    required this.todaySales,
    required this.todayOrdersCount,
    required this.monthSales,
    required this.monthOrdersCount,
    required this.pendingOrders,
    required this.processingOrders,
    required this.onHoldOrders,
    required this.completedOrders,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.orderStatuses,
    required this.recentOrders,
    required this.weeklySales,
    required this.storeName,
    required this.storeUrl,
    required this.currency,
    required this.currencySymbol,
  });

  factory DashboardStatsModel.empty() {
    return DashboardStatsModel(
      todaySales: 0,
      todayOrdersCount: 0,
      monthSales: 0,
      monthOrdersCount: 0,
      pendingOrders: 0,
      processingOrders: 0,
      onHoldOrders: 0,
      completedOrders: 0,
      lowStockCount: 0,
      outOfStockCount: 0,
      orderStatuses: {},
      recentOrders: [],
      weeklySales: [],
      storeName: '',
      storeUrl: '',
      currency: 'IRT',
      currencySymbol: 'تومان',
    );
  }

  factory DashboardStatsModel.fromPluginJson(Map<String, dynamic> json) {
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};
    final store = json['store'] as Map<String, dynamic>? ?? {};
    final rawStatuses = json['order_statuses'] as Map<String, dynamic>? ?? {};

    Map<String, int> statuses = {};
    rawStatuses.forEach((k, v) {
      statuses[k] = int.tryParse(v.toString()) ?? 0;
    });

    final rawRecent = json['recent_orders'] as List? ?? [];
    List<OrderModel> recent = [];
    for (var item in rawRecent) {
      if (item is Map<String, dynamic>) {
        recent.add(OrderModel(
          id: item['id'] as int? ?? 0,
          number: item['order_number']?.toString() ?? '',
          status: item['status']?.toString() ?? 'pending',
          dateCreated: item['date_created']?.toString() ?? '',
          total: double.tryParse(item['total']?.toString() ?? '0') ?? 0,
          subtotal: 0,
          shippingTotal: 0,
          discountTotal: 0,
          totalTax: 0,
          currency: item['currency']?.toString() ?? 'IRT',
          currencySymbol: item['currency_symbol']?.toString() ?? 'تومان',
          paymentMethodTitle: '',
          customerNote: '',
          billing: OrderAddress(
            firstName: item['customer_name']?.toString() ?? '',
            lastName: '',
            company: '',
            address1: '',
            address2: '',
            city: '',
            state: '',
            postcode: '',
            country: '',
            email: '',
            phone: item['customer_phone']?.toString() ?? '',
          ),
          shipping: OrderAddress(
            firstName: '',
            lastName: '',
            company: '',
            address1: '',
            address2: '',
            city: '',
            state: '',
            postcode: '',
            country: '',
            email: '',
            phone: '',
          ),
          lineItems: [],
        ));
      }
    }

    final rawWeekly = json['weekly_sales'] as List? ?? [];
    List<DailySalesModel> weekly = rawWeekly
        .map((e) => DailySalesModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardStatsModel(
      todaySales: double.tryParse(kpis['today_sales']?.toString() ?? '0') ?? 0,
      todayOrdersCount: int.tryParse(kpis['today_orders_count']?.toString() ?? '0') ?? 0,
      monthSales: double.tryParse(kpis['month_sales']?.toString() ?? '0') ?? 0,
      monthOrdersCount: int.tryParse(kpis['month_orders_count']?.toString() ?? '0') ?? 0,
      pendingOrders: int.tryParse(kpis['pending_orders']?.toString() ?? '0') ?? 0,
      processingOrders: int.tryParse(kpis['processing_orders']?.toString() ?? '0') ?? 0,
      onHoldOrders: int.tryParse(kpis['on_hold_orders']?.toString() ?? '0') ?? 0,
      completedOrders: int.tryParse(kpis['completed_orders']?.toString() ?? '0') ?? 0,
      lowStockCount: int.tryParse(kpis['low_stock_count']?.toString() ?? '0') ?? 0,
      outOfStockCount: int.tryParse(kpis['out_of_stock_count']?.toString() ?? '0') ?? 0,
      orderStatuses: statuses,
      recentOrders: recent,
      weeklySales: weekly,
      storeName: store['name']?.toString() ?? '',
      storeUrl: store['url']?.toString() ?? '',
      currency: store['currency']?.toString() ?? 'IRT',
      currencySymbol: store['currency_symbol']?.toString() ?? 'تومان',
    );
  }
}
