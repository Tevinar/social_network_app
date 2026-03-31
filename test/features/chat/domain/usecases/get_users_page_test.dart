import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/repositories/users_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_page.dart';

class MockUsersRepository extends Mock implements UsersRepository {}

void main() {
  late MockUsersRepository usersRepository;
  late GetUsersPage usecase;

  const users = [
    User(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
  ];

  setUp(() {
    usersRepository = MockUsersRepository();
    usecase = GetUsersPage(usersRepository: usersRepository);
  });

  test(
    'given a page number when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => usersRepository.getUsersPage(2),
      ).thenAnswer((_) async => right<Failure, List<User>>(users));

      // Act
      final result = await usecase(2);

      // Assert
      expect(result, right<Failure, List<User>>(users));
      verify(() => usersRepository.getUsersPage(2)).called(1);
    },
  );
}
