import 'package:intl/intl.dart';

String formatToDay(DateTime dateTime) {
  DateTime now = DateTime.now();
  if (dateTime.day == now.day) {
    return 'Today';
  } else if (dateTime.day + 1 == now.day) {
    return 'Yesturday';
  }
  return DateFormat('d MMM, yyyy').format(dateTime);
}

String formatToHour(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}
