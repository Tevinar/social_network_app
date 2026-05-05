import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late SecureAuthSessionStore store;

  final session = AuthSessionModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAt: DateTime.utc(2026),
    refreshTokenExpiresAt: DateTime.utc(2026, 2),
  );

  setUp(() {
    storage = MockFlutterSecureStorage();
    store = SecureAuthSessionStore(storage);
  });

  group('getSession', () {
    test(
      'given no stored session when getSession is called then returns null',
      () async {
        // Arrange
        when(
          () => storage.read(key: any<String>(named: 'key')),
        ).thenAnswer((_) async => null);

        // Act
        final result = await store.getSession();

        // Assert
        expect(result, isNull);
      },
    );

    test(
      'given a stored session when getSession is called then returns an '
      'AuthSessionModel',
      () async {
        // Arrange
        when(
          () => storage.read(key: any<String>(named: 'key')),
        ).thenAnswer((_) async => jsonEncode(session.toJson()));

        // Act
        final result = await store.getSession();

        // Assert
        expect(result?.accessToken, 'access-token');
        expect(result?.refreshToken, 'refresh-token');
        expect(result?.accessTokenExpiresAt, DateTime.utc(2026));
      },
    );
  });

  group('saveSession', () {
    test(
      'given a session when saveSession is called then writes it to secure '
      'storage',
      () async {
        // Arrange
        when(
          () => storage.write(
            key: any<String>(named: 'key'),
            value: any<String>(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await store.saveSession(session);

        // Assert
        final captured =
            verify(
                  () => storage.write(
                    key: 'auth_session',
                    value: captureAny<String>(named: 'value'),
                  ),
                ).captured.single
                as String;

        expect(jsonDecode(captured), equals(session.toJson()));
      },
    );
  });

  group('clearSession', () {
    test(
      'given clearSession is called then deletes the stored session',
      () async {
        // Arrange
        when(
          () => storage.delete(key: any<String>(named: 'key')),
        ).thenAnswer((_) async {});

        // Act
        await store.clearSession();

        // Assert
        verify(() => storage.delete(key: 'auth_session')).called(1);
      },
    );
  });

  group('watchSession', () {
    test(
      'given no stored session when watching then emits null followed by '
      'saved session changes',
      () async {
        // Arrange
        when(
          () => storage.read(key: any<String>(named: 'key')),
        ).thenAnswer((_) async => null);
        when(
          () => storage.write(
            key: any<String>(named: 'key'),
            value: any<String>(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        final emitted = <AuthSessionModel?>[];
        final subscription = store.watchSession().listen(emitted.add);
        await pumpEventQueue();

        // Act
        await store.saveSession(session);
        await pumpEventQueue();

        // Assert
        expect(emitted, <AuthSessionModel?>[null, session]);

        await subscription.cancel();
      },
    );

    test(
      'given a saved session when clearSession is called then watchSession '
      'emits null',
      () async {
        // Arrange
        when(
          () => storage.read(key: any<String>(named: 'key')),
        ).thenAnswer((_) async => jsonEncode(session.toJson()));
        when(
          () => storage.delete(key: any<String>(named: 'key')),
        ).thenAnswer((_) async {});

        final emitted = <AuthSessionModel?>[];
        final subscription = store.watchSession().listen(emitted.add);
        await pumpEventQueue();

        // Act
        await store.clearSession();
        await pumpEventQueue();

        // Assert
        expect(emitted.length, 2);
        expect(emitted.first?.accessToken, 'access-token');
        expect(emitted.last, isNull);

        await subscription.cancel();
      },
    );
  });
}
