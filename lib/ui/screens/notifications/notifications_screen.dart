import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/notification_provider.dart';
import '../orders/order_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = notifProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مرکز اعلان‌ها', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('خواندن همه', style: TextStyle(fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'پاکسازی همه اعلان‌ها',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('پاکسازی اعلان‌ها'),
                    content: const Text('آیا می‌خواهید تمامی اعلان‌های قبلی پاک شوند؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        onPressed: () {
                          Navigator.pop(context);
                          notifProvider.clearAll();
                        },
                        child: const Text('پاکسازی'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // بنر آزمایشی ارسال نوتیفیکیشن
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سیستم پوش‌نوتیفیکیشن فعال است',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'با ثبت سفارش موفق در سایت، اعلان با صدا ارسال می‌شود',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => notifProvider.triggerTestNotification(),
                  child: const Text('تست اعلان'),
                ),
              ],
            ),
          ),

          // لیست اعلان‌ها
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'هنوز اعلانی ثبت نشده است.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => notifProvider.triggerTestNotification(),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('ارسال اعلان آزمایشی'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final isUnread = !notif.isRead;

                      return Container(
                        decoration: BoxDecoration(
                          color: isUnread
                              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF))
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isUnread
                                ? AppColors.primary.withOpacity(0.4)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: notif.type == 'order_new'
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              notif.type == 'order_new'
                                  ? Icons.shopping_bag_rounded
                                  : Icons.notifications_rounded,
                              color: notif.type == 'order_new' ? AppColors.success : AppColors.primary,
                              size: 22,
                            ),
                          ),
                          title: Row(
                            children: [
                              if (isUnread) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                style: const TextStyle(fontSize: 12, height: 1.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormatter.timeAgo(notif.timestamp),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: notif.orderId != null
                              ? IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                  onPressed: () {
                                    notifProvider.markAsRead(notif.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailsScreen(orderId: notif.orderId!),
                                      ),
                                    );
                                  },
                                )
                              : null,
                          onTap: () {
                            notifProvider.markAsRead(notif.id);
                            if (notif.orderId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(orderId: notif.orderId!),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
