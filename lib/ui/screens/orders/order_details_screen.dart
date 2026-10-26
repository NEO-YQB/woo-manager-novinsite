import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/communication_service.dart';
import '../../widgets/status_badge.dart';
import 'invoice_preview_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final OrderModel? initialOrder;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderModel? _order;
  List<OrderNote> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    setState(() => _isLoading = true);
    final api = context.read<AuthProvider>().apiService;
    try {
      final fetchedOrder = await api.getOrder(widget.orderId);
      final fetchedNotes = await api.getOrderNotes(widget.orderId);
      setState(() {
        _order = fetchedOrder;
        _notes = fetchedNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showChangeStatusDialog() {
    if (_order == null) return;

    final statuses = [
      {'key': 'processing', 'title': 'در حال انجام (Processing)'},
      {'key': 'completed', 'title': 'تکمیل شده (Completed)'},
      {'key': 'on-hold', 'title': 'در انتظار بررسی (On hold)'},
      {'key': 'pending', 'title': 'در انتظار پرداخت (Pending payment)'},
      {'key': 'cancelled', 'title': 'لغو شده (Cancelled)'},
      {'key': 'refunded', 'title': 'مسترد شده (Refunded)'},
      {'key': 'failed', 'title': 'ناموفق (Failed)'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'تغییر وضعیت سفارش',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const Divider(),
                ...statuses.map((item) {
                  final isCurrent = _order!.status == item['key'];
                  return ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.getStatusColor(item['key']!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      item['title']!,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? AppColors.primary : null,
                      ),
                    ),
                    trailing: isCurrent ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () async {
                      Navigator.pop(context);
                      final ordersProvider = context.read<OrdersProvider>();
                      final success = await ordersProvider.updateOrderStatus(_order!.id, item['key']!);
                      if (success) {
                        setState(() {
                          _order = _order!.copyWith(status: item['key']);
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('وضعیت سفارش بروزرسانی شد.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController();
    bool isCustomerNote = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('افزودن یادداشت به سفارش'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'متن یادداشت را اینجا بنویسید...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('ارسال به مشتری (ایمیل)', style: TextStyle(fontSize: 13)),
                    value: isCustomerNote,
                    onChanged: (val) {
                      setDialogState(() {
                        isCustomerNote = val ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (noteController.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    final ordersProvider = context.read<OrdersProvider>();
                    final success = await ordersProvider.addOrderNote(
                      _order!.id,
                      noteController.text.trim(),
                      isCustomerNote,
                    );
                    if (success) {
                      _fetchOrderData();
                    }
                  },
                  child: const Text('ثبت یادداشت'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('سفارش #${widget.orderId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطا در دریافت سفارش')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'سفارش یافت نشد.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchOrderData, child: const Text('تلاش مجدد')),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سفارش #${PriceFormatter.toPersianDigits(order.number)}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'صدور و چاپ فاکتور',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoicePreviewScreen(order: order),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بنر وضعیت و دکمه تغییر وضعیت
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'وضعیت سفارش:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      StatusBadge(status: order.status, fontSize: 13),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showChangeStatusDialog,
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('تغییر وضعیت'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // بخش ارتباط با مشتری (تماس، واتساپ، پیامک)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
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
                      Text(
                        order.customerFullName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      if (order.customerPhone.isNotEmpty)
                        Text(
                          PriceFormatter.toPersianDigits(order.customerPhone),
                          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // تماس صوتی
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: order.customerPhone.isNotEmpty
                              ? () => CommunicationService.makePhoneCall(order.customerPhone)
                              : null,
                          icon: const Icon(Icons.phone_rounded, size: 18, color: AppColors.success),
                          label: const Text('تماس تلفنی', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // واتساپ
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: order.customerPhone.isNotEmpty
                              ? () {
                                  final msg = CommunicationService.generateOrderMessageTemplate(
                                    customerName: order.customerFullName,
                                    orderNumber: order.number,
                                    storeName: settings.sellerName.isNotEmpty ? settings.sellerName : 'فروشگاه ما',
                                    statusFa: order.statusFa,
                                  );
                                  CommunicationService.openWhatsApp(
                                    phoneNumber: order.customerPhone,
                                    message: msg,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF25D366)),
                          label: const Text('واتساپ', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // پیامک
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: order.customerPhone.isNotEmpty
                              ? () {
                                  final msg = CommunicationService.generateOrderMessageTemplate(
                                    customerName: order.customerFullName,
                                    orderNumber: order.number,
                                    storeName: settings.sellerName.isNotEmpty ? settings.sellerName : 'فروشگاه ما',
                                    statusFa: order.statusFa,
                                  );
                                  CommunicationService.sendSms(order.customerPhone, message: msg);
                                }
                              : null,
                          icon: const Icon(Icons.sms_rounded, size: 18, color: AppColors.primary),
                          label: const Text('پیامک', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // دکمه صدور و پرینت فاکتور
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoicePreviewScreen(order: order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                icon: const Icon(Icons.receipt_rounded),
                label: const Text('صدور و چاپ فاکتور رسمی PDF', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 20),

            // اقلام سفارش (Line items)
            const Text(
              'اقلام سفارش',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.lineItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = order.lineItems[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: item.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${PriceFormatter.toPersianDigits(item.quantity.toString())} عدد × ${PriceFormatter.format(item.price, currencySymbol: order.currencySymbol)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        PriceFormatter.format(item.total, currencySymbol: order.currencySymbol),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // خلاصه مالی
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryItem('هزینه ارسال', PriceFormatter.format(order.shippingTotal, currencySymbol: order.currencySymbol)),
                  if (order.discountTotal > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryItem('تخفیف', PriceFormatter.format(order.discountTotal, currencySymbol: order.currencySymbol), isDiscount: true),
                  ],
                  const SizedBox(height: 8),
                  _buildSummaryItem('شیوه پرداخت', order.paymentMethodTitle.isNotEmpty ? order.paymentMethodTitle : 'آنلاین'),
                  const Divider(height: 20),
                  _buildSummaryItem(
                    'مجموع نهایی پرداختی',
                    PriceFormatter.format(order.total, currencySymbol: order.currencySymbol),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // آدرس ارسال و صورتحساب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('آدرس صورتحساب و ارسال', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    order.billing.fullAddress,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                  if (order.customerNote.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('یادداشت مشتری:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(order.customerNote, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // یادداشت‌های سفارش
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('یادداشت‌های سفارش', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                TextButton.icon(
                  onPressed: _showAddNoteDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('افزودن یادداشت'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_notes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('یادداشتی برای این سفارش ثبت نشده است.', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final n = _notes[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: n.customerNote ? AppColors.primary.withOpacity(0.06) : Colors.grey.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              n.customerNote ? 'پیام برای مشتری' : 'یادداشت خصوصی',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: n.customerNote ? AppColors.primary : Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormatter.timeAgo(n.dateCreated),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(n.note, style: const TextStyle(fontSize: 13, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? null : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isDiscount ? AppColors.danger : (isBold ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }
}
