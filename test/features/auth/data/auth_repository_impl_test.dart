import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/data_sources/'
    'auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/data/repositories/'
    'auth_repository_impl.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAppLogger logger;
  late AuthRepositoryImpl repository;

  const userModel = UserModel(
    id: '123',
    email: 'test@test.com',
    name: 'Test',
  );

  setUp(() async {
    await GetIt.I.reset();
    remote = MockAuthRemoteDataSource();
    logger = MockAppLogger();

    GetIt.I.registerSingleton<AppLogger>(logger);

    repository = AuthRepositoryImpl(authRemoteDataSource: remote);
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
        ).thenAnswer((_) async => userModel);

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
        ).thenAnswer((_) async => userModel);

        // Act
        final result = await repository.signUpWithEmailPassword(
          name: 'Test',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, isA<Right<Failure, User>>());
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
  });

  group('authStateChanges', () {
    test(
      'Given remote emits UserModel when listening to auth changes, then '
      'Right<User> is emitted',
      () async {
        // Arrange
        when(
          () => remote.authStateChanges(),
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
      'Given remote emits null when listening to auth changes, then '
      'Right(null) is emitted',
      () async {
        // Arrange
        when(
          () => remote.authStateChanges(),
        ).thenAnswer((_) => Stream.value(null));

        // Act & Assert
        await expectLater(
          repository.authStateChanges(),
          emits(const Right<Failure, User?>(null)),
        );
      },
    );

    test(
      'Given remote stream throws when listening to auth changes, then '
      'Left<Failure> is emitted',
      () async {
        // Arrange
        when(() => remote.authStateChanges()).thenAnswer(
          (_) => Stream.error(const NetworkException(message: 'boom')),
        );

        // Act & Assert
        await expectLater(
          repository.authStateChanges(),
          emits(isA<Left<Failure, User?>>()),
        );
      },
    );
  });
}
