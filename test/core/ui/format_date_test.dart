import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';

void main() {
  group('formatToDay', () {
    test('returns Today when date is today', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 30);

      // Act
      final result = formatToDay(today);

      // Assert
      expect(result, 'Today');
    });

    test('returns Yesterday when date is yesterday', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final value = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        59,
      );

      // Act
      final result = formatToDay(value);

      // Assert
      expect(result, 'Yesterday');
    });

    test('formats other dates as d MMM, yyyy', () {
      // Arrange
      final value = DateTime(2000, 1, 2, 5, 7);

      // Act
      final result = formatToDay(value);

      // Assert
      expect(result, '2 Jan, 2000');
    });
  });

  group('formatToHour', () {
    test('formats hour as HH:mm with leading zeros', () {
      // Arrange
      final value = DateTime(2020, 1, 1, 5, 7);

      // Act
      final result = formatToHour(value);

      // Assert
      expect(result, '05:07');
    });
  });
}
