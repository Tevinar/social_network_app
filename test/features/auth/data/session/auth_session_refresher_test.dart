import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/local_database/app_settings_store.dart';
import 'package:social_app/core/local_database/schema/app_settings.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/session/auth_session_refresher.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';

class MockDio extends Mock implements Dio {}

class MockAppSettingsStore extends Mock implements AppSettingsStore {}

class MockAuthSessionStore extends Mock implements AuthSessionStore {}

void main() {
  late MockDio dio;
  late MockAppSettingsStore appSettingsStore;
  late MockAuthSessionStore authSessionStore;
  late BackendAuthSessionRefresher refresher;

  const deviceId = '00000000-0000-4000-8000-000000000000';
  final existingSession = AuthSessionModel(
    accessToken: 'stale-access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAt: DateTime.utc(2026),
    refreshTokenExpiresAt: DateTime.utc(2026, 2),
  );
  final refreshedSessionJson = <String, dynamic>{
    'accessToken': 'fresh-access-token',
    'refreshToken': 'fresh-refresh-token',
    'accessTokenExpiresAt': '2026-01-05T00:00:00.000Z',
    'refreshTokenExpiresAt': '2026-02-05T00:00:00.000Z',
  };

  setUpAll(() {
    registerFallbackValue(
      AuthSessionModel(
        accessToken: 'fallback-access-token',
        refreshToken: 'fallback-refresh-token',
        accessTokenExpiresAt: DateTime.utc(2026),
        refreshTokenExpiresAt: DateTime.utc(2026, 2),
      ),
    );
  });

  setUp(() {
    dio = MockDio();
    appSettingsStore = MockAppSettingsStore();
    authSessionStore = MockAuthSessionStore();
    refresher = BackendAuthSessionRefresher(
      dio: dio,
      appSettingsStore: appSettingsStore,
      authSessionStore: authSessionStore,
    );

    when(
      () => appSettingsStore.getOrCreate(
        key: AppSettingKey.deviceId,
        create: any(named: 'create'),
      ),
    ).thenAnswer((_) async => deviceId);
    when(() => authSessionStore.saveSession(any())).thenAnswer((_) async {});
  });

  group('refreshSession', () {
    test(
      'given a stored session when refresh succeeds then persists and returns '
      'the new session',
      () async {
        // Arrange
        when(
          () => authSessionStore.getSession(),
        ).thenAnswer((_) async => existingSession);
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            data: refreshedSessionJson,
          ),
        );

        // Act
        final result = await refresher.refreshSession();

        // Assert
        expect(result.accessToken, 'fresh-access-token');
        expect(result.refreshToken, 'fresh-refresh-token');

        final payload =
            verify(
                  () => dio.post<Map<String, dynamic>>(
                    '/auth/refresh',
                    data: captureAny<dynamic>(named: 'data'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(
          payload,
          equals(<String, dynamic>{
            'refreshToken': 'refresh-token',
            'deviceId': deviceId,
          }),
        );

        final savedSession =
            verify(
                  () => authSessionStore.saveSession(captureAny()),
                ).captured.single
                as AuthSessionModel;
        expect(savedSession.accessToken, 'fresh-access-token');
        expect(savedSession.refreshToken, 'fresh-refresh-token');
      },
    );

    test(
      'given no stored session when refresh is requested then throws '
      'UnauthorizedException',
      () async {
        // Arrange
        when(() => authSessionStore.getSession()).thenAnswer((_) async => null);

        // Act
        final result = refresher.refreshSession();

        // Assert
        await expectLater(result, throwsA(isA<UnauthorizedException>()));
      },
    );

    test(
      'given the backend returns an empty body when refresh succeeds then '
      'throws InvalidResponseException',
      () async {
        // Arrange
        when(
          () => authSessionStore.getSession(),
        ).thenAnswer((_) async => existingSession);
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/refresh'),
          ),
        );

        // Act
        final result = refresher.refreshSession();

        // Assert
        await expectLater(result, throwsA(isA<InvalidResponseException>()));
      },
    );
  });
}
