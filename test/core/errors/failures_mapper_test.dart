import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failure_messages.dart';
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
        expect(
          failure.message,
          'Unable to reach the server. Check your connection and try again.',
        );
        expect(failure.debugMessage, 'debug message');
      },
    );

    test(
      'given a ServerException with unauthorized code when '
      'mapExceptionToFailure is called '
      'then returns UnauthorizedFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Token expired',
          code: 'unauthorized',
          statusCode: 401,
        );

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
      'given a ServerException with forbidden code when '
      'mapExceptionToFailure is called then returns ForbiddenFailure',
      () {
        final error = _serverException(
          message: 'Forbidden',
          code: 'forbidden',
          statusCode: 403,
        );

        final failure = mapExceptionToFailure(error);

        expect(failure, isA<ForbiddenFailure>());
      },
    );

    test(
      'given a ServerException with not_found code when '
      'mapExceptionToFailure is called '
      'then returns NotFoundFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Resource not found',
          code: 'not_found',
          statusCode: 404,
        );

        // Act
        final failure = mapExceptionToFailure(error);

        // Assert
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, 'Requested resource not found.');
        expect(failure.debugMessage, 'Resource not found');
      },
    );

    test(
      'given a ServerException with email_already_in_use when '
      'mapExceptionToFailure is called then returns ValidationFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Email already exists in persistence',
          code: 'email_already_in_use',
          statusCode: 409,
        );

        // Act
        final failure = mapExceptionToFailure(error);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, AuthFailureMessages.emailAlreadyInUse);
        expect(failure.debugMessage, 'Email already exists in persistence');
      },
    );

    test(
      'given a ServerException with an unknown code and 400 status when '
      'mapExceptionToFailure is called then returns ValidationFailure from '
      'status fallback',
      () {
        // Arrange
        final error = _serverException(
          message: 'Unrecognized validation payload',
          code: 'unknown_validation_code',
          statusCode: 400,
        );

        // Act
        final failure = mapExceptionToFailure(error);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, CommonFailureMessages.invalidRequest);
        expect(failure.debugMessage, 'Unrecognized validation payload');
      },
    );

    test(
      'given a ServerException with an unknown code when '
      'mapExceptionToFailure is called then returns UnexpectedFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Weird backend error',
          code: '99999',
          statusCode: 500,
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
      'given an InvalidResponseException when mapExceptionToFailure is called '
      'then returns UnexpectedFailure',
      () {
        const error = InvalidResponseException(
          message: 'Response body is missing',
        );

        final failure = mapExceptionToFailure(error);

        expect(failure, isA<UnexpectedFailure>());
        expect(failure.debugMessage, 'Response body is missing');
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

ServerException _serverException({
  required String message,
  required String code,
  required int statusCode,
}) {
  return ServerException(
    message: message,
    code: code,
    statusCode: statusCode,
    path: '/test',
    timestamp: DateTime.parse('2026-05-12T10:00:00.000Z'),
  );
}
