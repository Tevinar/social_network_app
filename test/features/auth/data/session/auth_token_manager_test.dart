import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/session/auth_session_refresher.dart';
import 'package:social_app/features/auth/data/session/auth_token_manager.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:social_app/features/auth/data/sources/local/current_auth_user_store.dart';

class MockAuthSessionStore extends Mock implements AuthSessionStore {}

class MockCurrentAuthUserStore extends Mock implements CurrentAuthUserStore {}

class MockBackendAuthSessionRefresher extends Mock
    implements BackendAuthSessionRefresher {}

void main() {
  late MockAuthSessionStore authSessionStore;
  late MockCurrentAuthUserStore currentAuthUserStore;
  late MockBackendAuthSessionRefresher authSessionRefresher;
  late AuthTokenManager tokenManager;

  AuthSessionModel buildSession({
    required String accessToken,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
    String refreshToken = 'refresh-token',
  }) {
    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
    );
  }

  setUp(() {
    authSessionStore = MockAuthSessionStore();
    currentAuthUserStore = MockCurrentAuthUserStore();
    authSessionRefresher = MockBackendAuthSessionRefresher();
    tokenManager = AuthTokenManager(
      authSessionStore: authSessionStore,
      currentAuthUserStore: currentAuthUserStore,
      authSessionRefresher: authSessionRefresher,
    );

    when(() => authSessionStore.clearSession()).thenAnswer((_) async {});
    when(
      () => currentAuthUserStore.clearCurrentUser(),
    ).thenAnswer((_) async {});
  });

  group('getValidAccessToken', () {
    test(
      'given a session with a comfortably valid access token when requested '
      'then returns it without refreshing',
      () async {
        // Arrange
        final session = buildSession(
          accessToken: 'current-access-token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 5)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 1)),
        );
        when(
          () => authSessionStore.getSession(),
        ).thenAnswer((_) async => session);

        // Act
        final result = await tokenManager.getValidAccessToken();

        // Assert
        expect(result, 'current-access-token');
        verifyNever(() => authSessionRefresher.refreshSession());
      },
    );

    test(
      'given a session close to access-token expiry when requested then '
      'refreshes before returning a token',
      () async {
        // Arrange
        final storedSession = buildSession(
          accessToken: 'stale-access-token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(seconds: 30)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 1)),
        );
        final refreshedSession = buildSession(
          accessToken: 'fresh-access-token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 10)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 2)),
          refreshToken: 'fresh-refresh-token',
        );
        when(
          () => authSessionStore.getSession(),
        ).thenAnswer((_) async => storedSession);
        when(
          () => authSessionRefresher.refreshSession(),
        ).thenAnswer((_) async => refreshedSession);

        // Act
        final result = await tokenManager.getValidAccessToken();

        // Assert
        expect(result, 'fresh-access-token');
        verify(() => authSessionRefresher.refreshSession()).called(1);
      },
    );

    test(
      'given an expired refresh token when requested then clears local auth '
      'state and throws UnauthorizedException',
      () async {
        // Arrange
        final expiredSession = buildSession(
          accessToken: 'stale-access-token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 5)),
          refreshTokenExpiresAt: DateTime.now().subtract(
            const Duration(seconds: 1),
          ),
        );
        when(
          () => authSessionStore.getSession(),
        ).thenAnswer((_) async => expiredSession);

        // Act
        final result = tokenManager.getValidAccessToken();

        // Assert
        await expectLater(result, throwsA(isA<UnauthorizedException>()));
        verify(() => authSessionStore.clearSession()).called(1);
        verify(() => currentAuthUserStore.clearCurrentUser()).called(1);
      },
    );
  });

  group('forceRefreshAccessToken', () {
    test(
      'given concurrent refresh requests when a refresh is already in flight '
      'then shares the same refresh operation',
      () async {
        // Arrange
        final completer = Completer<AuthSessionModel>();
        when(
          () => authSessionRefresher.refreshSession(),
        ).thenAnswer((_) => completer.future);

        // Act
        final first = tokenManager.forceRefreshAccessToken();
        final second = tokenManager.forceRefreshAccessToken();
        completer.complete(
          buildSession(
            accessToken: 'fresh-access-token',
            accessTokenExpiresAt: DateTime.now().add(
              const Duration(minutes: 10),
            ),
            refreshTokenExpiresAt: DateTime.now().add(
              const Duration(days: 1),
            ),
            refreshToken: 'fresh-refresh-token',
          ),
        );
        final results = await Future.wait([first, second]);

        // Assert
        expect(results, ['fresh-access-token', 'fresh-access-token']);
        verify(() => authSessionRefresher.refreshSession()).called(1);
      },
    );
  });
}
