import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatWithUnit(num amount, String rateType) {
    final formatted = format(amount);
    switch (rateType.toLowerCase()) {
      case 'hourly':
        return '$formatted/hr';
      case 'daily':
        return '$formatted/day';
      case 'fixed':
        return '$formatted (Fixed)';
      default:
        return formatted;
    }
  }
}
