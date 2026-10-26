import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/invoice_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final OrderModel order;

  const InvoicePreviewScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('فاکتور سفارش #${order.number}', style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'اشتراک‌گذاری فاکتور',
            onPressed: () {
              InvoiceService.shareInvoice(
                order: order,
                storeName: settings.sellerName.isNotEmpty ? settings.sellerName : 'فروشگاه اینترنتی',
                sellerPhone: settings.sellerPhone,
                sellerAddress: settings.sellerAddress,
                footerNote: settings.footerNote,
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => InvoiceService.generateInvoicePdf(
          order: order,
          storeName: settings.sellerName.isNotEmpty ? settings.sellerName : 'فروشگاه اینترنتی',
          sellerPhone: settings.sellerPhone,
          sellerAddress: settings.sellerAddress,
          footerNote: settings.footerNote,
        ),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text('در حال آماده‌سازی و رندر فاکتور فارسی...', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        pdfFileName: 'Invoice_Order_${order.number}.pdf',
      ),
    );
  }
}
