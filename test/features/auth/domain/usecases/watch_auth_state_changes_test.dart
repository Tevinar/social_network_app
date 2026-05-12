import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/watch_auth_state_changes_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late WatchAuthStateChanges watchAuthStateChanges;

  const user = User(
    id: 'user-1',
    name: 'Alice',
    email: 'alice@test.com',
  );

  setUp(() {
    authRepository = MockAuthRepository();
    watchAuthStateChanges = WatchAuthStateChanges(
      authRepository: authRepository,
    );
  });

  test(
    'given the use case is called when the repository emits auth changes then '
    'it forwards the stream',
    () async {
      when(() => authRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(const Right<Failure, User?>(user)),
      );

      final emissions = await watchAuthStateChanges().toList();

      expect(emissions, [const Right<Failure, User?>(user)]);
      verify(() => authRepository.authStateChanges()).called(1);
    },
  );
}
