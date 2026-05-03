import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_cases/use_case.dart';
import 'package:social_app/features/chat/domain/repositories/users_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_count.dart';

class MockUsersRepository extends Mock implements UsersRepository {}

void main() {
  late MockUsersRepository usersRepository;
  late GetUsersCount usecase;

  setUp(() {
    usersRepository = MockUsersRepository();
    usecase = GetUsersCount(usersRepository: usersRepository);
  });

  test(
    'given NoParams when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => usersRepository.getUsersCount(),
      ).thenAnswer((_) async => right<Failure, int>(2));

      // Act
      final result = await usecase(const NoParams());

      // Assert
      expect(result, right<Failure, int>(2));
      verify(() => usersRepository.getUsersCount()).called(1);
    },
  );
}
