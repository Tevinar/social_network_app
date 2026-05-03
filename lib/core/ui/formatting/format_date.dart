import 'package:intl/intl.dart';

DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

/// Checks if two [DateTime] objects represent the same calendar day.
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Formats [dateTime] into a day label such as `Today`, `Yesterday`, or a
/// calendar date.
String formatToDay(DateTime dateTime) {
  final now = DateTime.now();
  final today = _dateOnly(now);
  final yesterday = _dateOnly(now.subtract(const Duration(days: 1)));
  final value = _dateOnly(dateTime);

  if (isSameDay(value, today)) {
    return 'Today';
  } else if (isSameDay(value, yesterday)) {
    return 'Yesterday';
  }
  return DateFormat('d MMM, yyyy').format(dateTime);
}

/// Formats [dateTime] into a 24-hour clock string.
String formatToHour(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}
