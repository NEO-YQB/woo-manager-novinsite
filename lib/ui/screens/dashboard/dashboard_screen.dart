import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../notifications/notifications_screen.dart';
import '../orders/order_details_screen.dart';
import '../products/product_edit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<DashboardProvider>().loadDashboard();
      if (mounted) {
        final recent = context.read<DashboardProvider>().stats.recentOrders;
        final notif = context.read<NotificationProvider>();
        final api = context.read<AuthProvider>().apiService;
        await notif.checkNewOrders(recent);
        await notif.syncRemoteNotifications(api);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashProvider = context.watch<DashboardProvider>();
    final stats = dashProvider.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.storeName.isNotEmpty ? authProvider.storeName : 'مدیریت فروشگاه نوین سایت',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'متصل به فروشگاه',
                        style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // زنگوله اعلان‌ها همراه با بج تعداد خوانده‌نشده
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, child) {
              final unread = notifProvider.unreadCount;
              return IconButton(
                icon: Badge.count(
                  count: unread,
                  isLabelVisible: unread > 0,
                  backgroundColor: AppColors.danger,
                  child: const Icon(Icons.notifications_outlined),
                ),
                tooltip: 'مرکز اعلان‌ها',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: dashProvider.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            tooltip: 'بروزرسانی اطلاعات',
            onPressed: () async {
              await dashProvider.loadDashboard(forceRefresh: true);
              if (mounted) {
                final recent = dashProvider.stats.recentOrders;
                final notif = context.read<NotificationProvider>();
                final api = authProvider.apiService;
                await notif.checkNewOrders(recent);
                await notif.syncRemoteNotifications(api);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dashProvider.loadDashboard(forceRefresh: true);
          if (mounted) {
            final recent = dashProvider.stats.recentOrders;
            final notif = context.read<NotificationProvider>();
            final api = authProvider.apiService;
            await notif.checkNewOrders(recent);
            await notif.syncRemoteNotifications(api);
          }
        },
        color: AppColors.primary,
        child: dashProvider.isLoading && stats.recentOrders.isEmpty
            ? const SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    ShimmerCardList(count: 4, height: 100),
                    ShimmerCardList(count: 3, height: 80),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // کارت‌های شاخص (KPIs Grid)
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.25,
                      children: [
                        StatCard(
                          title: 'فروش امروز',
                          value: PriceFormatter.format(
                            stats.todaySales,
                            currencySymbol: stats.currencySymbol,
                          ),
                          subtitle: '${PriceFormatter.toPersianDigits(stats.todayOrdersCount.toString())} سفارش امروز',
                          icon: Icons.payments_rounded,
                          gradient: AppColors.emeraldGradient,
                        ),
                        StatCard(
                          title: 'در حال انجام',
                          value: PriceFormatter.toPersianDigits(stats.processingOrders.toString()),
                          subtitle: 'سفارشات پردازشی',
                          icon: Icons.local_shipping_rounded,
                          gradient: AppColors.primaryGradient,
                        ),
                        StatCard(
                          title: 'در انتظار پرداخت',
                          value: PriceFormatter.toPersianDigits(stats.pendingOrders.toString()),
                          subtitle: 'نیاز به پیگیری',
                          icon: Icons.hourglass_top_rounded,
                          gradient: AppColors.amberGradient,
                        ),
                        StatCard(
                          title: 'هشدار انبار',
                          value: PriceFormatter.toPersianDigits((stats.lowStockCount + stats.outOfStockCount).toString()),
                          subtitle: '${PriceFormatter.toPersianDigits(stats.outOfStockCount.toString())} کالای ناموجود',
                          icon: Icons.warning_amber_rounded,
                          gradient: AppColors.purpleGradient,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // نمودار درآمد و روند فروش
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'روند فروش و سفارشات',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '۷ روز اخیر',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Builder(
                            builder: (context) {
                              final hasWeekly = stats.weeklySales.isNotEmpty;
                              final List<double> values = hasWeekly
                                  ? stats.weeklySales.map((w) => w.ordersCount.toDouble()).toList()
                                  : [0, 0, 0, 0, 0, 0, 0];

                              double maxVal = 5;
                              for (var v in values) {
                                if (v > maxVal) maxVal = v;
                              }

                              return SizedBox(
                                height: 160,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: maxVal + 1,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          final count = rod.toY.toInt();
                                          String dayName = '';
                                          if (hasWeekly && groupIndex < stats.weeklySales.length) {
                                            dayName = stats.weeklySales[groupIndex].day;
                                          }
                                          return BarTooltipItem(
                                            '$dayName: $count سفارش',
                                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final idx = value.toInt();
                                            String label = '';
                                            if (hasWeekly && idx >= 0 && idx < stats.weeklySales.length) {
                                              label = stats.weeklySales[idx].day;
                                            } else {
                                              const days = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
                                              if (idx >= 0 && idx < days.length) label = days[idx];
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? Colors.white60 : Colors.black54,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(
                                      values.length,
                                      (i) => _makeGroupData(i, values[i], maxVal + 1),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // اقدامات سریع (Quick Actions)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductEditScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_box_rounded, size: 18),
                            label: const Text('ثبت محصول'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              dashProvider.loadDashboard(forceRefresh: true);
                            },
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('همگام‌سازی'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // آخرین سفارش‌ها (Recent Orders)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'سفارش‌های لحظه‌ای اخیر',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${PriceFormatter.toPersianDigits(stats.recentOrders.length.toString())} سفارش',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (stats.recentOrders.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Text('هنوز سفارشی ثبت نشده است.'),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stats.recentOrders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = stats.recentOrders[index];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsScreen(orderId: order.id),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '#${PriceFormatter.toPersianDigits(order.number)} - ${order.customerFullName}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              StatusBadge(status: order.status, fontSize: 11),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                PriceFormatter.format(
                                                  order.total,
                                                  currencySymbol: order.currencySymbol,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              Text(
                                                DateFormatter.timeAgo(order.dateCreated),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, [double maxY = 10]) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
