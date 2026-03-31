import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_out.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late UserSignOut userSignOut;

  setUp(() {
    authRepository = MockAuthRepository();
    userSignOut = UserSignOut(authRepository: authRepository);
  });

  group('UserSignOut', () {
    test(
      'given repository succeeds when UserSignOut is called then returns '
      'Right<void> and calls signOut',
      () async {
        // Arrange
        when(
          () => authRepository.signOut(),
        ).thenAnswer((_) async => const Right<Failure, void>(null));

        // Act
        final result = await userSignOut(NoParams());

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => authRepository.signOut()).called(1);
      },
    );

    test(
      'given repository fails when UserSignOut is called then returns '
      'Left<Failure>',
      () async {
        // Arrange
        when(
          () => authRepository.signOut(),
        ).thenAnswer((_) async => left(const UnauthorizedFailure()));

        // Act
        final result = await userSignOut(NoParams());

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnauthorizedFailure>()),
          (_) => fail('Expected a failure'),
        );
      },
    );
  });
}
