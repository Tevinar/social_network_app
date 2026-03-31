import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';

void main() {
  group('mapExceptionToFailure', () {
    test(
      'given a NetworkException when mapExceptionToFailure is called then '
      'returns NetworkFailure with the correct message and debug message',
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

    test(
      'given a ServerException with 401 when mapExceptionToFailure is called '
      'then returns UnauthorizedFailure',
      () {
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
      },
    );

    test(
      'given a ServerException with 403 when mapExceptionToFailure is called '
      'then returns UnauthorizedFailure',
      () {
      const error = ServerException(message: 'Forbidden', code: '403');

      final failure = mapExceptionToFailure(error);

      expect(failure, isA<UnauthorizedFailure>());
      },
    );

    test(
      'given a ServerException with 404 when mapExceptionToFailure is called '
      'then returns NotFoundFailure',
      () {
      // Arrange
      const error = ServerException(message: 'Resource not found', code: '404');

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, 'Requested resource not found.');
      expect(failure.debugMessage, 'Resource not found');
      },
    );

    test(
      'given a ServerException with 23505 when mapExceptionToFailure is '
      'called then returns ValidationFailure for duplicate values',
      () {
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
      },
    );

    test(
      'given a ServerException with 23502 when mapExceptionToFailure is '
      'called then returns ValidationFailure for missing field',
      () {
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
      },
    );

    test(
      'given a ServerException with an unknown code when '
      'mapExceptionToFailure is called then returns UnexpectedFailure',
      () {
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
      },
    );

    test(
      'given an unknown exception when mapExceptionToFailure is called then '
      'returns UnexpectedFailure',
      () {
      // Arrange
      final error = Exception('Some random exception');

      // Act
      final failure = mapExceptionToFailure(error);

      // Assert
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'Something went wrong. Please try again.');
      expect(failure.debugMessage, error.toString());
      },
    );
  });
}
