import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_in.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late UserSignIn userSignIn;

  const testUser = User(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  setUp(() {
    authRepository = MockAuthRepository();
    userSignIn = UserSignIn(authRepositoy: authRepository);
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
  });
}
