import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/local_database/app_settings_store.dart';
import 'package:social_app/core/local_database/schema/app_settings.dart';
import 'package:social_app/features/auth/data/data_sources/'
    'auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/data_sources/auth_session_store.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';

class MockDio extends Mock implements Dio {}

class MockAppSettingsStore extends Mock implements AppSettingsStore {}

class MockAuthSessionStore extends Mock implements AuthSessionStore {}

void main() {
  late MockDio dio;
  late MockAppSettingsStore appSettingsStore;
  late MockAuthSessionStore authSessionStore;
  late AuthRemoteDataSourceImpl dataSource;

  const deviceId = '00000000-0000-4000-8000-000000000000';
  final authSessionJson = <String, dynamic>{
    'user': <String, dynamic>{
      'id': '123',
      'email': 'test@test.com',
      'name': 'Test User',
    },
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'accessTokenExpiresAt': '2026-01-01T00:00:00.000Z',
    'refreshTokenExpiresAt': '2026-02-01T00:00:00.000Z',
  };
  final authSessionModel = AuthSessionModel.fromJson(authSessionJson);

  setUpAll(() {
    registerFallbackValue(
      AuthSessionModel(
        accessToken: 'fallback-access-token',
        refreshToken: 'fallback-refresh-token',
        accessTokenExpiresAt: DateTime.utc(2026),
        refreshTokenExpiresAt: DateTime.utc(2026, 2),
        user: const UserModel(
          id: 'fallback-user-id',
          name: 'Fallback User',
          email: 'fallback@test.com',
        ),
      ),
    );
  });

  setUp(() {
    dio = MockDio();
    appSettingsStore = MockAppSettingsStore();
    authSessionStore = MockAuthSessionStore();
    dataSource = AuthRemoteDataSourceImpl(
      appSettingsStore: appSettingsStore,
      dio: dio,
      authSessionStore: authSessionStore,
    );
    when(
      () => appSettingsStore.getOrCreate(
        key: AppSettingKey.deviceId,
        create: any(named: 'create'),
      ),
    ).thenAnswer((_) async => deviceId);
    when(
      () => authSessionStore.saveSession(any()),
    ).thenAnswer((_) async {});
    when(
      () => authSessionStore.clearSession(),
    ).thenAnswer((_) async {});
  });

  group('signInWithEmailPassword', () {
    test(
      'given backend returns an auth session when signing in then returns '
      'the user and stores the session',
      () async {
        // Arrange
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/sign-in'),
            data: authSessionJson,
          ),
        );

        // Act
        final result = await dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(
          result,
          isA<UserModel>()
              .having((user) => user.id, 'id', '123')
              .having((user) => user.name, 'name', 'Test User')
              .having((user) => user.email, 'email', 'test@test.com'),
        );
        verify(
          () => authSessionStore.saveSession(
            any(
              that: isA<AuthSessionModel>()
                  .having(
                    (session) => session.accessToken,
                    'accessToken',
                    'access-token',
                  )
                  .having(
                    (session) => session.refreshToken,
                    'refreshToken',
                    'refresh-token',
                  ),
            ),
          ),
        ).called(1);

        final capturedData = verify(
          () => dio.post<Map<String, dynamic>>(
            '/auth/sign-in',
            data: captureAny<dynamic>(named: 'data'),
          ),
        ).captured.single;

        expect(
          capturedData,
          equals(<String, dynamic>{
            'email': 'test@test.com',
            'password': 'password',
            'deviceId': deviceId,
          }),
        );
      },
    );

    test(
      'given backend returns an empty body when signing in then throws '
      'ServerException',
      () async {
        // Arrange
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/sign-in'),
          ),
        );

        // Act
        final result = dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'given Dio reports a connection error when signing in then throws '
      'NetworkException',
      () async {
        // Arrange
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/sign-in'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act
        final result = dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('signUpWithEmailPassword', () {
    test(
      'given backend returns an auth session when signing up then returns '
      'the user and stores the session',
      () async {
        // Arrange
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/sign-up'),
            data: authSessionJson,
          ),
        );

        // Act
        final result = await dataSource.signUpWithEmailPassword(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result.id, '123');
        expect(result.name, 'Test User');
        expect(result.email, 'test@test.com');
        verify(
          () => authSessionStore.saveSession(
            any(
              that: isA<AuthSessionModel>().having(
                (session) => session.accessToken,
                'accessToken',
                'access-token',
              ),
            ),
          ),
        ).called(1);

        final capturedData = verify(
          () => dio.post<Map<String, dynamic>>(
            '/auth/sign-up',
            data: captureAny<dynamic>(named: 'data'),
          ),
        ).captured.single;

        expect(
          capturedData,
          equals(<String, dynamic>{
            'name': 'Test User',
            'email': 'test@test.com',
            'password': 'password',
            'deviceId': deviceId,
          }),
        );
      },
    );

    test(
      'given backend returns an invalid user shape when signing up then '
      'throws ServerException',
      () async {
        // Arrange
        when(
          () => dio.post<Map<String, dynamic>>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/sign-up'),
            data: <String, dynamic>{...authSessionJson, 'user': null},
          ),
        );

        // Act
        final result = dataSource.signUpWithEmailPassword(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );
  });

  group('signOut', () {
    test(
      'given no stored session when signing out then clears local session '
      'without calling the backend',
      () async {
        // Arrange
        when(() => authSessionStore.getSession()).thenAnswer((_) async => null);

        // Act
        await dataSource.signOut();

        // Assert
        verify(() => authSessionStore.clearSession()).called(1);
        verifyNever(
          () => dio.post<void>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        );
      },
    );

    test(
      'given a stored session when signing out then revokes the backend '
      'session and clears local state',
      () async {
        // Arrange
        when(
          () => authSessionStore.getSession(),
        ).thenAnswer((_) async => authSessionModel);
        when(
          () => dio.post<void>(
            any(),
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: '/auth/sign-out'),
          ),
        );

        // Act
        await dataSource.signOut();

        // Assert
        verify(() => authSessionStore.clearSession()).called(1);

        final capturedData = verify(
          () => dio.post<void>(
            '/auth/sign-out',
            data: captureAny<dynamic>(named: 'data'),
          ),
        ).captured.single;

        expect(
          capturedData,
          equals(<String, dynamic>{
            'refreshToken': 'refresh-token',
            'deviceId': deviceId,
          }),
        );
      },
    );
  });
}
