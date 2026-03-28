import 'dart:io';

import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_app/core/errors/exceptions.dart';

void main() {
  group('guardRemoteDataSourceCall', () {
    test('returns value when call succeeds', () async {
      // Act
      final int result = await guardRemoteDataSourceCall(() async {
        return 42;
      });

      // Assert
      expect(result, 42);
    });

    test(
      'translates PostgrestException into ServerException with code',
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

    test('translates SocketException into NetworkException', () async {
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
    });

    test('translates unknown exception into ServerException', () async {
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
    });
  });
}
