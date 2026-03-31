import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
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
      'given a PostgrestException when guardRemoteDataSourceCall is invoked '
      'then throws ServerException with code',
      () async {
        // Arrange
        const exception = PostgrestException(
          message: 'Database error',
          code: '23505',
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
                .having((e) => e.code, 'code', '23505'),
          ),
        );
      },
    );

    test(
      'given a SocketException when guardRemoteDataSourceCall is invoked '
      'then throws NetworkException',
      () async {
      // Arrange
      const exception = SocketException('No internet');

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
      'then throws ServerException',
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
          isA<ServerException>().having(
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
