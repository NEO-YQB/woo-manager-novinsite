import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/price_formatter.dart';
import '../data/models/order_model.dart';

class InvoiceService {
  /// تولید بایت‌های فایل PDF فاکتور با رندرینگ کامل فونت فارسی وزیرمتن
  static Future<Uint8List> generateInvoicePdf({
    required OrderModel order,
    String? storeName = 'فروشگاه اینترنتی',
    String? sellerPhone,
    String? sellerAddress,
    String? footerNote,
  }) async {
    final pdf = pw.Document();

    // بارگذاری فونت استاندارد فارسی برای پشتیبانی کامل از حروف و ارقام فارسی
    final ttfRegular = await PdfGoogleFonts.vazirmatnRegular();
    final ttfBold = await PdfGoogleFonts.vazirmatnBold();

    final dateFa = DateFormatter.format(order.dateCreated, useShamsi: true);
    final currencyTitle = order.currencySymbol.isNotEmpty ? order.currencySymbol : 'تومان';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: ttfRegular,
          bold: ttfBold,
        ),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // هدر فاکتور
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          storeName ?? 'فروشگاه اینترنتی',
                          style: pw.TextStyle(font: ttfBold, fontSize: 18, color: PdfColors.indigo900),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'فاکتور رسمی فروش کالا و خدمات',
                          style: pw.TextStyle(font: ttfRegular, fontSize: 12, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'شماره سفارش: #${PriceFormatter.toPersianDigits(order.number)}',
                          style: pw.TextStyle(font: ttfBold, fontSize: 13, color: PdfColors.indigo700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'تاریخ: $dateFa',
                          style: pw.TextStyle(font: ttfRegular, fontSize: 11, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'وضعیت: ${order.statusFa}',
                            style: pw.TextStyle(font: ttfBold, fontSize: 10, color: PdfColors.grey800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.grey400, thickness: 1),
                pw.SizedBox(height: 10),

                // مشخصات فروشنده و خریدار در دو ستون
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // فروشنده
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey50,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          border: pw.Border.all(color: PdfColors.grey200),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('مشخصات فروشنده:', style: pw.TextStyle(font: ttfBold, fontSize: 11)),
                            pw.SizedBox(height: 4),
                            pw.Text('نام: ${storeName ?? "فروشگاه"}', style: const pw.TextStyle(fontSize: 10)),
                            if (sellerPhone != null && sellerPhone.isNotEmpty)
                              pw.Text('تلفن تماس: ${PriceFormatter.toPersianDigits(sellerPhone)}', style: const pw.TextStyle(fontSize: 10)),
                            if (sellerAddress != null && sellerAddress.isNotEmpty)
                              pw.Text('نشانی: $sellerAddress', style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    // خریدار
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey50,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          border: pw.Border.all(color: PdfColors.grey200),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('مشخصات خریدار:', style: pw.TextStyle(font: ttfBold, fontSize: 11)),
                            pw.SizedBox(height: 4),
                            pw.Text('نام: ${order.customerFullName}', style: const pw.TextStyle(fontSize: 10)),
                            if (order.customerPhone.isNotEmpty)
                              pw.Text('تلفن: ${PriceFormatter.toPersianDigits(order.customerPhone)}', style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('نشانی: ${order.billing.fullAddress}', style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // جدول اقلام
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                  children: [
                    // سربرگ جدول
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableCell('ردیف', ttfBold, isHeader: true, flex: 1),
                        _buildTableCell('شرح کالا / خدمات', ttfBold, isHeader: true, flex: 6),
                        _buildTableCell('تعداد', ttfBold, isHeader: true, flex: 2),
                        _buildTableCell('قیمت واحد ($currencyTitle)', ttfBold, isHeader: true, flex: 3),
                        _buildTableCell('مبلغ کل ($currencyTitle)', ttfBold, isHeader: true, flex: 3),
                      ],
                    ),
                    // ردیف‌های اقلام
                    ...List.generate(order.lineItems.length, (index) {
                      final item = order.lineItems[index];
                      return pw.TableRow(
                        children: [
                          _buildTableCell(PriceFormatter.toPersianDigits((index + 1).toString()), ttfRegular),
                          _buildTableCell(item.name, ttfRegular, alignRight: true),
                          _buildTableCell(PriceFormatter.toPersianDigits(item.quantity.toString()), ttfRegular),
                          _buildTableCell(PriceFormatter.format(item.price, showCurrency: false), ttfRegular),
                          _buildTableCell(PriceFormatter.format(item.total, showCurrency: false), ttfRegular),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 14),

                // جمع محاسبات مالی و یادداشت
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // یادداشت مشتری و توضیحات
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (order.customerNote.isNotEmpty) ...[
                            pw.Text('یادداشت مشتری:', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                            pw.Text(order.customerNote, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                            pw.SizedBox(height: 8),
                          ],
                          pw.Text(
                            'شیوه پرداخت: ${order.paymentMethodTitle.isNotEmpty ? order.paymentMethodTitle : "پرداخت آنلاین"}',
                            style: pw.TextStyle(font: ttfRegular, fontSize: 10),
                          ),
                          pw.SizedBox(height: 12),
                          // بارکد / QR کد استعلام
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: 'ORDER:#${order.number} TOTAL:${order.total}',
                            width: 60,
                            height: 60,
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    // جدول جمع کل
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Column(
                          children: [
                            _buildSummaryRow('جمع کل اقلام:', PriceFormatter.format(order.total - order.shippingTotal, currencySymbol: currencyTitle), ttfRegular),
                            if (order.shippingTotal > 0) ...[
                              pw.SizedBox(height: 4),
                              _buildSummaryRow('هزینه ارسال:', PriceFormatter.format(order.shippingTotal, currencySymbol: currencyTitle), ttfRegular),
                            ],
                            if (order.discountTotal > 0) ...[
                              pw.SizedBox(height: 4),
                              _buildSummaryRow('تخفیف:', PriceFormatter.format(order.discountTotal, currencySymbol: currencyTitle), ttfRegular),
                            ],
                            pw.Divider(color: PdfColors.grey400),
                            pw.SizedBox(height: 4),
                            _buildSummaryRow('مبلغ نهایی پرداختی:', PriceFormatter.format(order.total, currencySymbol: currencyTitle), ttfBold, isBold: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // فوتر فاکتور و امضا
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      footerNote ?? 'از خرید و اعتماد شما سپاسگزاریم.',
                      style: pw.TextStyle(font: ttfRegular, fontSize: 9, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      'مهر و امضای فروشگاه',
                      style: pw.TextStyle(font: ttfBold, fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    bool alignRight = false,
    int flex = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, pw.Font font, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: isBold ? 11 : 10)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: isBold ? 11 : 10, color: isBold ? PdfColors.indigo900 : PdfColors.black)),
      ],
    );
  }

  /// پیش‌نمایش و چاپ مستقیم فاکتور در پرینترهای متصل
  static Future<void> printInvoice({
    required OrderModel order,
    String? storeName,
    String? sellerPhone,
    String? sellerAddress,
    String? footerNote,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      order: order,
      storeName: storeName,
      sellerPhone: sellerPhone,
      sellerAddress: sellerAddress,
      footerNote: footerNote,
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  /// اشتراک‌گذاری فایل فاکتور PDF در پیام‌رسان‌ها
  static Future<void> shareInvoice({
    required OrderModel order,
    String? storeName,
    String? sellerPhone,
    String? sellerAddress,
    String? footerNote,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      order: order,
      storeName: storeName,
      sellerPhone: sellerPhone,
      sellerAddress: sellerAddress,
      footerNote: footerNote,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invoice_Order_${order.number}.pdf',
    );
  }
}
