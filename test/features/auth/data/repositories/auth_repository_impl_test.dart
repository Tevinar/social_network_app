import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/models/authenticated_user_model.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/data/sources/local/current_auth_user_store.dart';
import 'package:social_app/features/auth/data/sources/remote/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:social_app/features/auth/data/repositories/'
    'auth_repository_impl.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthSessionStore extends Mock implements AuthSessionStore {}

class MockCurrentAuthUserStore extends Mock implements CurrentAuthUserStore {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthSessionStore sessionStore;
  late MockCurrentAuthUserStore currentAuthUserStore;
  late MockAppLogger logger;
  late AuthRepositoryImpl repository;

  const userModel = UserModel(
    id: '123',
    email: 'test@test.com',
    name: 'Test',
  );
  final sessionModel = AuthSessionModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAt: DateTime.utc(2026),
    refreshTokenExpiresAt: DateTime.utc(2026, 2),
  );
  late AuthenticatedUserModel authenticatedUserModel;

  setUpAll(() {
    registerFallbackValue(userModel);
    registerFallbackValue(sessionModel);
  });

  setUp(() async {
    await GetIt.I.reset();
    remote = MockAuthRemoteDataSource();
    sessionStore = MockAuthSessionStore();
    currentAuthUserStore = MockCurrentAuthUserStore();
    logger = MockAppLogger();
    authenticatedUserModel = AuthenticatedUserModel(
      session: sessionModel,
      user: userModel,
    );

    GetIt.I.registerSingleton<AppLogger>(logger);

    when(() => currentAuthUserStore.saveCurrentUser(any())).thenAnswer(
      (_) async {},
    );
    when(
      () => currentAuthUserStore.clearCurrentUser(),
    ).thenAnswer((_) async {});
    when(() => sessionStore.saveSession(any())).thenAnswer((_) async {});
    when(() => sessionStore.clearSession()).thenAnswer((_) async {});

    repository = AuthRepositoryImpl(
      authRemoteDataSource: remote,
      authSessionStore: sessionStore,
      currentAuthUserStore: currentAuthUserStore,
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('signInWithEmailPassword', () {
    test(
      'Given remote succeeds when signing in with email and password, then '
      'Right<User> is returned',
      () async {
        // Arrange
        when(
          () => remote.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => authenticatedUserModel);

        // Act
        final result = await repository.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(
          result,
          isA<Right<Failure, User>>()
              .having((r) => r.value.id, 'id', '123')
              .having((r) => r.value.email, 'email', 'test@test.com')
              .having((r) => r.value.name, 'name', 'Test'),
        );
        verify(() => currentAuthUserStore.saveCurrentUser(userModel)).called(1);
        verify(() => sessionStore.saveSession(sessionModel)).called(1);
      },
    );

    test(
      'Given remote throws when signing in with email and password, then '
      'Left<Failure> is returned',
      () async {
        // Arrange
        when(
          () => remote.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const NetworkException(message: 'no internet'));

        // Act
        final result = await repository.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    test(
      'Given remote throws an unexpected exception when signing in with '
      'email and password, then Left<Failure> is returned and the error is '
      'logged',
      () async {
        // Arrange
        when(
          () => remote.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const ServerException(message: 'unexpected sign-in error'));

        // Act
        final result = await repository.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('Expected failure'),
        );

        verify(
          () => logger.error(
            'Unexpected error in AuthRepositoryImpl.signInWithEmailPassword',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('signUpWithEmailPassword', () {
    test(
      'Given remote succeeds when signing up with email and password, then '
      'Right<User> is returned',
      () async {
        // Arrange
        when(
          () => remote.signUpWithEmailPassword(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => authenticatedUserModel);

        // Act
        final result = await repository.signUpWithEmailPassword(
          name: 'Test',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, isA<Right<Failure, User>>());
        verify(() => currentAuthUserStore.saveCurrentUser(userModel)).called(1);
        verify(() => sessionStore.saveSession(sessionModel)).called(1);
      },
    );

    test(
      'Given remote throws when signing up with email and password, then '
      'Left<Failure> is returned',
      () async {
        // Arrange
        when(
          () => remote.signUpWithEmailPassword(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const ServerException(message: 'error'));

        // Act
        final result = await repository.signUpWithEmailPassword(
          name: 'Test',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, isA<Left<Failure, User>>());

        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('Expected failure'),
        );

        verify(
          () => logger.error(
            'Unexpected error in AuthRepositoryImpl.signUpWithEmailPassword',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('signOut', () {
    test(
      'Given remote succeeds When signing out Then Right<void> is returned',
      () async {
        // Arrange
        when(() => remote.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => remote.signOut()).called(1);
        verify(() => sessionStore.clearSession()).called(1);
        verify(() => currentAuthUserStore.clearCurrentUser()).called(1);
      },
    );

    test(
      'Given remote throws When signing out Then Left<Failure> is returned',
      () async {
        // Arrange
        when(
          () => remote.signOut(),
        ).thenThrow(const NetworkException(message: 'offline'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    test(
      'Given remote throws an unexpected exception when signing out, then '
      'Left<Failure> is returned and the error is logged',
      () async {
        // Arrange
        when(
          () => remote.signOut(),
        ).thenThrow(
          const ServerException(message: 'unexpected sign-out error'),
        );

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('Expected failure'),
        );

        verify(
          () => logger.error(
            'Unexpected error in AuthRepositoryImpl.signOut',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('authStateChanges', () {
    test(
      'Given current user store emits a user when listening to auth changes, '
      'then Right<User> is emitted',
      () async {
        // Arrange
        when(
          () => currentAuthUserStore.watchCurrentUser(),
        ).thenAnswer((_) => Stream.value(userModel));

        // Act
        final stream = repository.authStateChanges();

        // Assert
        await expectLater(
          stream,
          emitsInOrder([
            isA<Right<Failure, User?>>()
                .having((r) => r.value!.id, 'id', '123')
                .having((r) => r.value!.email, 'email', 'test@test.com')
                .having((r) => r.value!.name, 'name', 'Test'),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'Given current user store emits null when listening to auth changes, then '
      'Right(null) is emitted',
      () async {
        // Arrange
        when(
          () => currentAuthUserStore.watchCurrentUser(),
        ).thenAnswer((_) => Stream.value(null));

        // Act & Assert
        await expectLater(
          repository.authStateChanges(),
          emits(const Right<Failure, User?>(null)),
        );
      },
    );

    test(
      'Given current user store stream throws when listening to auth changes, then '
      'Left<Failure> is emitted',
      () async {
        // Arrange
        when(() => currentAuthUserStore.watchCurrentUser()).thenAnswer(
          (_) => Stream.error(const NetworkException(message: 'boom')),
        );

        // Act & Assert
        await expectLater(
          repository.authStateChanges(),
          emits(isA<Left<Failure, User?>>()),
        );
      },
    );

    test(
      'Given current user store stream throws an unexpected exception when '
      'listening to auth changes, then Left<Failure> is emitted and the error '
      'is logged',
      () async {
        // Arrange
        when(() => currentAuthUserStore.watchCurrentUser()).thenAnswer(
          (_) => Stream.error(const ServerException(message: 'stream error')),
        );

        // Act
        final stream = repository.authStateChanges();

        // Assert
        await expectLater(stream, emits(isA<Left<Failure, User?>>()));
        verify(
          () => logger.error(
            'Unexpected error in AuthRepositoryImpl.authStateChanges',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });
}
