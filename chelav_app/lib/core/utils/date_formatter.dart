import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayFormat = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDayFormat = DateFormat('d MMM yyyy');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatFull(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today, ${_dayFormat.format(date)}';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, ${_dayFormat.format(date)}';
    }
    return _dayFormat.format(date);
  }

  static String formatDayHeader(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return _shortDayFormat.format(date);
  }

  static String formatMonth(DateTime date) {
    return _monthFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String toIsoDate(DateTime date) {
    return _isoFormat.format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
