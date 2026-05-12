import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';

void main() {
  final timestamp = DateTime.parse('2026-05-12T10:00:00.000Z');

  group('NetworkException', () {
    test(
      'given a NetworkException when toString is called then returns a '
      'readable string representation',
      () {
        // Arrange
        const exception = NetworkException(
          message: 'No internet connection',
          code: '408',
        );

        // Act
        final result = exception.toString();

        // Assert
        expect(
          result,
          'NetworkException: No internet connection (code: 408)',
        );
      },
    );
  });

  group('guardRemoteDataSourceCall', () {
    test(
      'given a successful call when guardRemoteDataSourceCall is invoked '
      'then returns the value',
      () async {
        // Act
        final result = await guardRemoteDataSourceCall(() async {
          return 42;
        });

        // Assert
        expect(result, 42);
      },
    );

    test(
      'given a DioException with a server payload when '
      'guardRemoteDataSourceCall is invoked '
      'then throws ServerException with code',
      () async {
        // Arrange
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 409,
            data: {
              'statusCode': 409,
              'message': 'Database error',
              'code': 'conflict',
              'path': '/test',
              'timestamp': timestamp.toIso8601String(),
            },
          ),
        );

        // Act
        Future<void> act() async {
          await guardRemoteDataSourceCall(() async {
            throw exception;
          });
        }

        // Assert 1
        await expectLater(
          act,
          throwsA(
            isA<ServerException>()
                .having((e) => e.message, 'message', 'Database error')
                .having((e) => e.code, 'code', 'conflict')
                .having((e) => e.statusCode, 'statusCode', 409)
                .having((e) => e.path, 'path', '/test')
                .having((e) => e.timestamp, 'timestamp', timestamp),
          ),
        );
      },
    );

    test(
      'given a network DioException when guardRemoteDataSourceCall is invoked '
      'then throws NetworkException',
      () async {
        // Arrange
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
          error: const SocketException('No internet'),
          message: 'No internet',
        );

        // Act
        Future<void> act() async {
          await guardRemoteDataSourceCall(() async {
            throw exception;
          });
        }

        // Assert
        await expectLater(
          act,
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'No internet',
            ),
          ),
        );
      },
    );

    test(
      'given an unknown exception when guardRemoteDataSourceCall is invoked '
      'then throws UnexpectedException',
      () async {
        // Arrange
        final exception = Exception('Something weird');

        // Act
        Future<void> act() async {
          await guardRemoteDataSourceCall(() async {
            throw exception;
          });
        }

        // Assert
        await expectLater(
          act,
          throwsA(
            isA<UnexpectedException>().having(
              (e) => e.message,
              'message',
              exception.toString(),
            ),
          ),
        );
      },
    );
  });
}
