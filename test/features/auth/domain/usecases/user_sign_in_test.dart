import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_in_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late UserSignInUseCase userSignIn;

  const testUser = User(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  setUp(() {
    authRepository = MockAuthRepository();
    userSignIn = UserSignInUseCase(authRepositoy: authRepository);
  });

  group('UserSignIn', () {
    test(
      'given repository succeeds when UserSignIn is called then returns '
      'Right<User> and passes the credentials',
      () async {
        // Arrange
        final params = UserSignInParams(
          email: 'test@test.com',
          password: 'password',
        );
        when(
          () => authRepository.signInWithEmailPassword(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => const Right(testUser));

        // Act
        final result = await userSignIn(params);

        // Assert
        expect(
          result,
          isA<Right<Failure, User>>()
              .having((r) => r.value.id, 'id', testUser.id)
              .having((r) => r.value.name, 'name', testUser.name)
              .having((r) => r.value.email, 'email', testUser.email),
        );
        verify(
          () => authRepository.signInWithEmailPassword(
            email: 'test@test.com',
            password: 'password',
          ),
        ).called(1);
      },
    );

    test(
      'given repository fails when UserSignIn is called then returns '
      'Left<Failure>',
      () async {
        // Arrange
        final params = UserSignInParams(
          email: 'test@test.com',
          password: 'password',
        );
        when(
          () => authRepository.signInWithEmailPassword(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => left(const NetworkFailure()));

        // Act
        final result = await userSignIn(params);

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected a failure'),
        );
      },
    );

    test(
      'given invalid email when UserSignIn is called then returns '
      'ValidationFailure and does not call repository',
      () async {
        // Arrange
        final params = UserSignInParams(
          email: 'invalid-email',
          password: 'password',
        );

        // Act
        final result = await userSignIn(params);

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(
            failure,
            isA<ValidationFailure>().having(
              (failure) => failure.message,
              'message',
              'Please enter a valid email address.',
            ),
          ),
          (_) => fail('Expected a failure'),
        );
        verifyNever(
          () => authRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    test(
      'given short password when UserSignIn is called then returns '
      'ValidationFailure and does not call repository',
      () async {
        // Arrange
        final params = UserSignInParams(
          email: 'test@test.com',
          password: '12345',
        );

        // Act
        final result = await userSignIn(params);

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(
            failure,
            isA<ValidationFailure>().having(
              (failure) => failure.message,
              'message',
              'Password must be at least 6 characters long.',
            ),
          ),
          (_) => fail('Expected a failure'),
        );
        verifyNever(
          () => authRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );
  });
}
