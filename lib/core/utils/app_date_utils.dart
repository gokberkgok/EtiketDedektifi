import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime addMonths(DateTime month, int delta) =>
      DateTime(month.year, month.month + delta);

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static bool isSameDay(DateTime a, DateTime b) =>
      isSameMonth(a, b) && a.day == b.day;

  static int daysBetween(DateTime start, DateTime end) {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    return endUtc.difference(startUtc).inDays;
  }

  static DateTime withTime(DateTime date, int hour, int minute) =>
      DateTime(date.year, date.month, date.day, hour, minute);
}

abstract final class AppDateFormatter {
  static const String locale = 'tr_TR';

  static String monthYear(DateTime date) =>
      DateFormat('MMMM y', locale).format(date);

  static String monthName(DateTime date) =>
      DateFormat('MMMM', locale).format(date);

  static String monthShort(DateTime date) =>
      DateFormat('MMM', locale).format(date);

  static String fullDate(DateTime date) =>
      DateFormat('d MMMM y', locale).format(date);

  static String dayMonth(DateTime date) =>
      DateFormat('d MMM', locale).format(date);

  static String weekday(DateTime date) =>
      DateFormat('EEEE', locale).format(date);

  static String time(DateTime date) => DateFormat('HH:mm', locale).format(date);

  static String dayLabel(DateTime date, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final difference = AppDateUtils.daysBetween(date, today);
    if (difference == 0) return 'Bugün';
    if (difference == 1) return 'Dün';
    if (difference == -1) return 'Yarın';
    return fullDate(date);
  }

  static String relativeDateTime(DateTime date, {DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final difference = AppDateUtils.daysBetween(date, today);
    final dayPart = switch (difference) {
      0 => 'Bugün',
      1 => 'Dün',
      -1 => 'Yarın',
      _ =>
        date.year == today.year
            ? dayMonth(date)
            : DateFormat('d MMM y', locale).format(date),
    };
    return '$dayPart, ${time(date)}';
  }
}
