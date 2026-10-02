import 'package:intl/intl.dart';

/// Utilities for working with DateTimes, day boundaries, and formatting.
class DateTimeUtils {
  DateTimeUtils._();

  static const List<String> _spanishMonthsFull = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  static const List<String> _spanishMonthsShort = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];

  /// Formats date for display: "27 septiembre 2026"
  static String formatFullDate(DateTime dateTime) {
    try {
      return DateFormat('d MMMM yyyy', 'es').format(dateTime);
    } catch (_) {
      final monthName = _spanishMonthsFull[dateTime.month - 1];
      return '${dateTime.day} $monthName ${dateTime.year}';
    }
  }

  /// Formats date for short display: "27 sep 2026"
  static String formatShortDate(DateTime dateTime) {
    try {
      return DateFormat('d MMM yyyy', 'es').format(dateTime);
    } catch (_) {
      final monthShort = _spanishMonthsShort[dateTime.month - 1];
      return '${dateTime.day} $monthShort ${dateTime.year}';
    }
  }

  /// Formats time in HH:mm (e.g. "08:30")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats time range: "22:30 → 07:00"
  static String formatTimeRange(DateTime start, DateTime end) {
    final startStr = formatTime(start);
    final endStr = formatTime(end);
    if (!isSameDay(start, end)) {
      return '$startStr → $endStr (+1d)';
    }
    return '$startStr → $endStr';
  }

  /// Checks if two DateTimes are on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns start of the day (00:00:00.000).
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
  }

  /// Returns end of the day (23:59:59.999).
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Checks if a given event starting at `start` belongs to the target day `day`.
  static bool eventBelongsToDay(DateTime start, DateTime day) {
    return isSameDay(start, day);
  }

  /// Calculates duration between start and end in minutes.
  static int durationInMinutes(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  /// Formats duration into human readable string: "1h 30m" or "45m"
  static String formatDuration(int minutes) {
    if (minutes < 0) return '0m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}
