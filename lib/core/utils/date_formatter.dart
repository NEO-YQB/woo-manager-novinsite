import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'price_formatter.dart';

class DateFormatter {
  static String format(
    dynamic dateInput, {
    bool useShamsi = true,
    bool includeTime = true,
    bool toPersian = true,
  }) {
    if (dateInput == null) return '';

    DateTime? dt;
    if (dateInput is DateTime) {
      dt = dateInput;
    } else if (dateInput is String) {
      dt = DateTime.tryParse(dateInput);
    }

    if (dt == null) return dateInput.toString();

    String result = '';
    if (useShamsi) {
      final jalali = Jalali.fromDateTime(dt);
      final year = jalali.year;
      final month = jalali.month.toString().padLeft(2, '0');
      final day = jalali.day.toString().padLeft(2, '0');

      if (includeTime) {
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        result = '$year/$month/$day - $hour:$minute';
      } else {
        result = '$year/$month/$day';
      }
    } else {
      final formatter = DateFormat(
        includeTime ? 'yyyy/MM/dd HH:mm' : 'yyyy/MM/dd',
      );
      result = formatter.format(dt);
    }

    if (toPersian) {
      result = PriceFormatter.toPersianDigits(result);
    }

    return result;
  }

  static String timeAgo(dynamic dateInput) {
    if (dateInput == null) return '';

    DateTime? dt;
    if (dateInput is DateTime) {
      dt = dateInput;
    } else if (dateInput is String) {
      dt = DateTime.tryParse(dateInput);
    }

    if (dt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inSeconds < 60) {
      return 'لحظاتی پیش';
    } else if (difference.inMinutes < 60) {
      return '${PriceFormatter.toPersianDigits(difference.inMinutes.toString())} دقیقه پیش';
    } else if (difference.inHours < 24) {
      return '${PriceFormatter.toPersianDigits(difference.inHours.toString())} ساعت پیش';
    } else if (difference.inDays == 1) {
      return 'دیروز';
    } else if (difference.inDays < 7) {
      return '${PriceFormatter.toPersianDigits(difference.inDays.toString())} روز پیش';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${PriceFormatter.toPersianDigits(weeks.toString())} هفته پیش';
    } else {
      return format(dt, includeTime: false);
    }
  }
}
