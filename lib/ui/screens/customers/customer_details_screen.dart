import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../data/models/customer_model.dart';
import '../../../services/communication_service.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت پروفایل
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      customer.firstName.isNotEmpty ? customer.firstName[0] : (customer.username.isNotEmpty ? customer.username[0] : '?'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    customer.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (customer.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                  if (customer.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      PriceFormatter.toPersianDigits(customer.phone),
                      style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // آمار خریدهای مشتری
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('تعداد کل سفارشات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            PriceFormatter.toPersianDigits(customer.ordersCount.toString()),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
                      Column(
                        children: [
                          const Text('مجموع خریدهای انجام شده', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            PriceFormatter.format(customer.totalSpent),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // دکمه‌های ارتباط سریع با مشتری
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: customer.phone.isNotEmpty
                        ? () => CommunicationService.makePhoneCall(customer.phone)
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('تماس تلفنی'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: customer.phone.isNotEmpty
                        ? () => CommunicationService.openWhatsApp(phoneNumber: customer.phone)
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: const Text('واتساپ'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // نشانی‌های مشتری
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
                  const Text('نشانی صورتحساب', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    customer.billing.fullAddress,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 14),
                  const Text('نشانی حمل و نقل و تحویل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    customer.shipping.fullAddress,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
