import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';

void main() {
  group('mapExceptionToFailure', () {
    test(
      'NetworkException gives a NetworkFailure '
      'with the correct message and debug message',
      () {
        // Arrange
        const error = NetworkException(message: 'debug message');

        // Act
        final failure = mapExceptionToFailure(error);

        // Assert
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'No internet connection.');
        expect(failure.debugMessage, 'debug message');
      },
    );

    test('ServerException with 401 → UnauthorizedFailure', () {
      // Arrange
      const error = ServerException(message: 'Token expired', code: '401');

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<UnauthorizedFailure>());
      expect(
        failure.message,
        'Your session has expired. Please sign in again.',
      );
      expect(failure.debugMessage, 'Token expired');
    });

    test('ServerException with 403 → UnauthorizedFailure', () {
      const error = ServerException(message: 'Forbidden', code: '403');

      final failure = mapExceptionToFailure(error);

      expect(failure, isA<UnauthorizedFailure>());
    });

    test('ServerException with 404 → NotFoundFailure', () {
      // Arrange
      const error = ServerException(message: 'Resource not found', code: '404');

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, 'Requested resource not found.');
      expect(failure.debugMessage, 'Resource not found');
    });

    test('ServerException with 23505 → ValidationFailure (duplicate)', () {
      // Arrange
      const error = ServerException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
      );

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'This value already exists.');
      expect(
        failure.debugMessage,
        'duplicate key value violates unique constraint',
      );
    });

    test('ServerException with 23502 → ValidationFailure (missing field)', () {
      // Arrange
      const error = ServerException(
        message: 'null value in column',
        code: '23502',
      );

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Some required information is missing.');
      expect(failure.debugMessage, 'null value in column');
    });

    test('ServerException with unknown code → UnexpectedFailure', () {
      // Arrange
      const error = ServerException(
        message: 'Weird backend error',
        code: '99999',
      );

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'Something went wrong. Please try again.');
      expect(failure.debugMessage, 'Weird backend error');
    });

    test('Unknown exception type → UnexpectedFailure', () {
      // Arrange
      final error = Exception('Some random exception');

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'Something went wrong. Please try again.');
      expect(failure.debugMessage, error.toString());
    });
  });
}
