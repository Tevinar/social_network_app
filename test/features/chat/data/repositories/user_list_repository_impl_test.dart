import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:social_app/features/chat/data/repositories/user_list_repository_impl.dart';

class MockUsersRemoteDataSource extends Mock implements UsersRemoteDataSource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockUsersRemoteDataSource remote;
  late MockAppLogger logger;
  late UsersRepositoryImpl repository;

  const userModel = UserModel(
    id: 'user-1',
    name: 'Alice',
    email: 'alice@test.com',
  );

  setUp(() async {
    await GetIt.I.reset();
    remote = MockUsersRemoteDataSource();
    logger = MockAppLogger();
    GetIt.I.registerSingleton<AppLogger>(logger);
    repository = UsersRepositoryImpl(usersRemoteDataSource: remote);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test(
    'given remote succeeds when getUsersPage is invoked then returns '
    'Right<List<User>>',
    () async {
      // Arrange
      when(() => remote.getUsersPage(2)).thenAnswer((_) async => [userModel]);

      // Act
      final result = await repository.getUsersPage(2);

      // Assert
      expect(result, isA<Right<Failure, dynamic>>());
      result.fold(
        (_) => fail('Expected success'),
        (users) {
          expect(users, hasLength(1));
          expect(users.first.id, userModel.id);
        },
      );
    },
  );

  test(
    'given an unexpected exception when getUsersPage is invoked then '
    'returns Left and logs the error',
    () async {
      // Arrange
      when(
        () => remote.getUsersPage(2),
      ).thenThrow(const ServerException(message: 'boom'));

      // Act
      final result = await repository.getUsersPage(2);

      // Assert
      expect(result, isA<Left<Failure, dynamic>>());
      verify(
        () => logger.error(
          'Unexpected error in UsersRepositoryImpl.getUsersPage',
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    },
  );

  test(
    'given remote succeeds when getUsersCount is invoked then returns '
    'Right<int>',
    () async {
      // Arrange
      when(() => remote.getUsersCount()).thenAnswer((_) async => 3);

      // Act
      final result = await repository.getUsersCount();

      // Assert
      expect(result, right<Failure, int>(3));
    },
  );

  test(
    'given an unexpected exception when getUsersCount is invoked then '
    'returns Left and logs the error',
    () async {
      // Arrange
      when(
        () => remote.getUsersCount(),
      ).thenThrow(const ServerException(message: 'boom'));

      // Act
      final result = await repository.getUsersCount();

      // Assert
      expect(result, isA<Left<Failure, dynamic>>());
      verify(
        () => logger.error(
          'Unexpected error in UsersRepositoryImpl.getUsersCount',
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    },
  );
}
