import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:social_app/features/chat/domain/repositories/users_repository.dart';

/// An users repository impl.
class UsersRepositoryImpl implements UsersRepository {
  /// Creates a [UsersRepositoryImpl].
  UsersRepositoryImpl({required this.usersRemoteDataSource});

  /// The users remote data source.
  UsersRemoteDataSource usersRemoteDataSource;

  @override
  Future<Either<Failure, List<UserEntity>>> getUsersPage(int pageNumber) async {
    try {
      final users = await usersRemoteDataSource.getUsersPage(
        pageNumber,
      );
      return right(users.map((userModel) => userModel.toEntity()).toList());
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in UsersRepositoryImpl.getUsersPage',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, int>> getUsersCount() async {
    try {
      final usersCount = await usersRemoteDataSource.getUsersCount();
      return right(usersCount);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in UsersRepositoryImpl.getUsersCount',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }
}
