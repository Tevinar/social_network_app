import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_app/core/utils/calculate_reading_time.dart';

void main() {
  group('calculateReadingTime', () {
    test('returns 1 minute for empty content', () {
      // Arrange
      const content = '';

      // Act
      final result = calculateReadingTime(content);

      // Assert
      expect(result, 1);
    });

    test('returns 1 minute for short content', () {
      // Arrange
      const content = 'Hello world';

      // Act
      final result = calculateReadingTime(content);

      // Assert
      expect(result, 1);
    });

    test('returns 1 minute for exactly 225 words', () {
      // Arrange
      final content = List.filled(225, 'word').join(' ');

      // Act
      final result = calculateReadingTime(content);

      // Assert
      expect(result, 1);
    });

    test('rounds up reading time when over 225 words', () {
      // Arrange
      final content = List.filled(226, 'word').join(' ');

      // Act
      final result = calculateReadingTime(content);

      // Assert
      expect(result, 2);
    });

    test('handles multiple spaces and new lines correctly', () {
      // Arrange
      const content = 'word   word\nword\tword';

      // Act
      final result = calculateReadingTime(content);

      // Assert
      expect(result, 1);
    });

    test('returns correct minutes for large content', () {
      // Arrange
      final content = List.filled(900, 'word').join(' ');

      // Act
      final result = calculateReadingTime(content);

      // Assert
      expect(result, 4); // 900 / 225 = 4
    });
  });
}
