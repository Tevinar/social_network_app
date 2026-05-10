import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_up_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late UserSignUpUseCase userSignUp;

  const testUser = User(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  setUp(() {
    authRepository = MockAuthRepository();
    userSignUp = UserSignUpUseCase(authRepository: authRepository);
  });

  group('UserSignUp', () {
    test(
      'given repository succeeds when UserSignUp is called then returns '
      'Right<User> and passes the credentials',
      () async {
        // Arrange
        final params = UserSignUpParams(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );
        when(
          () => authRepository.signUpWithEmailPassword(
            name: 'Test User',
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => const Right(testUser));

        // Act
        final result = await userSignUp(params);

        // Assert
        expect(
          result,
          isA<Right<Failure, User>>()
              .having((r) => r.value.id, 'id', testUser.id)
              .having((r) => r.value.name, 'name', testUser.name)
              .having((r) => r.value.email, 'email', testUser.email),
        );
        verify(
          () => authRepository.signUpWithEmailPassword(
            name: 'Test User',
            email: 'test@test.com',
            password: 'password',
          ),
        ).called(1);
      },
    );

    test(
      'given repository fails when UserSignUp is called then returns '
      'Left<Failure>',
      () async {
        // Arrange
        final params = UserSignUpParams(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );
        when(
          () => authRepository.signUpWithEmailPassword(
            name: 'Test User',
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => left(const ValidationFailure('Invalid')));

        // Act
        final result = await userSignUp(params);

        // Assert
        expect(result, isA<Left<Failure, User>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected a failure'),
        );
      },
    );

    test(
      'given invalid email when UserSignUp is called then returns '
      'ValidationFailure and does not call repository',
      () async {
        // Arrange
        final params = UserSignUpParams(
          name: 'Test User',
          email: 'invalid-email',
          password: 'password',
        );

        // Act
        final result = await userSignUp(params);

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
          () => authRepository.signUpWithEmailPassword(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    test(
      'given short password when UserSignUp is called then returns '
      'ValidationFailure and does not call repository',
      () async {
        // Arrange
        final params = UserSignUpParams(
          name: 'Test User',
          email: 'test@test.com',
          password: '12345',
        );

        // Act
        final result = await userSignUp(params);

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
          () => authRepository.signUpWithEmailPassword(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );
  });
}
