import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/orders_provider.dart';
import '../../../services/communication_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/status_badge.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final List<Map<String, String>> _statusFilters = [
    {'key': 'all', 'title': 'همه'},
    {'key': 'processing', 'title': 'در حال انجام'},
    {'key': 'pending', 'title': 'در انتظار پرداخت'},
    {'key': 'on-hold', 'title': 'در انتظار بررسی'},
    {'key': 'completed', 'title': 'تکمیل شده'},
    {'key': 'cancelled', 'title': 'لغو شده'},
    {'key': 'refunded', 'title': 'مسترد شده'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<OrdersProvider>().loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت سفارشات', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ordersProvider.loadOrders(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // فیلد جستجو
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجوی شماره سفارش، نام خریدار یا موبایل...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ordersProvider.searchOrders('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (val) => ordersProvider.searchOrders(val),
            ),
          ),

          // فیلتر تب‌های وضعیت
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _statusFilters[index];
                final isSelected = ordersProvider.selectedStatus == item['key'];

                return ChoiceChip(
                  label: Text(item['title']!),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                    fontFamily: 'Vazirmatn',
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      ordersProvider.filterByStatus(item['key']!);
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // لیست سفارشات
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ordersProvider.loadOrders(refresh: true),
              color: AppColors.primary,
              child: ordersProvider.isLoading && ordersProvider.orders.isEmpty
                  ? const ShimmerCardList(count: 6, height: 110)
                  : ordersProvider.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'سفارشی با این مشخصات یافت نشد.',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: ordersProvider.orders.length + (ordersProvider.hasMore ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index == ordersProvider.orders.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }

                            final order = ordersProvider.orders[index];
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // سطر شماره سفارش و وضعیت
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '#${PriceFormatter.toPersianDigits(order.number)}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                order.customerFullName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          StatusBadge(status: order.status),
                                        ],
                                      ),

                                      const SizedBox(height: 8),
                                      const Divider(height: 1, thickness: 0.5),
                                      const SizedBox(height: 8),

                                      // سطر مشخصات مالی و تاریخ
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                PriceFormatter.format(
                                                  order.total,
                                                  currencySymbol: order.currencySymbol,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${PriceFormatter.toPersianDigits(order.itemsCount.toString())} قلم کالا',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormatter.timeAgo(order.dateCreated),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // دکمه تماس سریع
                                              if (order.customerPhone.isNotEmpty)
                                                InkWell(
                                                  onTap: () => CommunicationService.makePhoneCall(order.customerPhone),
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.success.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.phone_in_talk_rounded, size: 14, color: AppColors.success),
                                                        SizedBox(width: 4),
                                                        Text('تماس سریع', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
