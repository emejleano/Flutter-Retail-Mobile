import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  /// Format an ISO 8601 string (e.g. "2025-12-21T06:23:45.000000Z" or "2025-12-21") to a clean date time string
  static String formatIsoString(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      // If there's no time component (just date), format as date only
      if (!isoString.contains('T') || isoString.endsWith('00:00:00.000000Z')) {
        return formatDate(date);
      }
      return formatDateTime(date);
    } catch (_) {
      // Fallback: just strip the Z and microseconds if parsing fails
      return isoString
          .replaceAll('T', ' ')
          .replaceAll(RegExp(r'\.\d+Z?$'), '')
          .replaceAll('Z', '');
    }
  }
  
  static String formatDateApi(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }
  
  static int dateToDateId(DateTime date) {
    return int.parse(DateFormat('yyyyMMdd').format(date));
  }
  
  static DateTime dateIdToDate(int dateId) {
    final str = dateId.toString();
    return DateTime(
      int.parse(str.substring(0, 4)),
      int.parse(str.substring(4, 6)),
      int.parse(str.substring(6, 8)),
    );
  }
  
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }
  
  static String formatNumber(num number) {
    return NumberFormat('#,##0').format(number);
  }
  
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  static String formatCompactNumber(num number) {
    return NumberFormat.compact().format(number);
  }
  
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }
  
  static String formatPeriod(String period) {
    final parts = period.split('-');
    if (parts.length == 2) {
      final year = parts[0];
      final month = int.parse(parts[1]);
      return '${getMonthName(month)} $year';
    }
    return period;
  }

  /// Format date_id (YYYYMMDD integer) to readable date string
  static String formatDateFromId(int dateId) {
    try {
      final date = dateIdToDate(dateId);
      return formatDate(date);
    } catch (_) {
      return dateId.toString();
    }
  }
}
