import 'package:intl/intl.dart';

class PriceFormatter {
  static const Map<String, String> _persianDigits = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '۴',
    '5': '۵',
    '6': '۶',
    '7': '۷',
    '8': '۸',
    '9': '۹',
  };

  static String toPersianDigits(String input) {
    var output = input;
    _persianDigits.forEach((en, fa) {
      output = output.replaceAll(en, fa);
    });
    return output;
  }

  static String format(
    dynamic amount, {
    String? currencySymbol = 'تومان',
    bool showCurrency = true,
    bool toPersian = true,
    int decimalDigits = 0,
  }) {
    if (amount == null) return '۰';

    double value = 0;
    if (amount is num) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    }

    if (value == 0) {
      return showCurrency ? 'رایگان' : (toPersian ? '۰' : '0');
    }

    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: decimalDigits,
    );

    String formatted = formatter.format(value).trim();

    if (toPersian) {
      formatted = toPersianDigits(formatted);
    }

    if (showCurrency && currencySymbol != null && currencySymbol.isNotEmpty) {
      return '$formatted $currencySymbol';
    }

    return formatted;
  }
}
