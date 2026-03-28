import 'package:intl/intl.dart';

DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatToDay(DateTime dateTime) {
  final now = DateTime.now();
  final DateTime today = _dateOnly(now);
  final DateTime yesterday = _dateOnly(now.subtract(const Duration(days: 1)));
  final DateTime value = _dateOnly(dateTime);

  if (_isSameDay(value, today)) {
    return 'Today';
  } else if (_isSameDay(value, yesterday)) {
    return 'Yesterday';
  }
  return DateFormat('d MMM, yyyy').format(dateTime);
}

String formatToHour(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}
