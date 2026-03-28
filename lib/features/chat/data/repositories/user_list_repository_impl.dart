import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:social_app/features/chat/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({required this.usersRemoteDataSource});
  UsersRemoteDataSource usersRemoteDataSource;

  @override
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber) async {
    try {
      final users = await usersRemoteDataSource.getUsersPage(
        pageNumber,
      );
      return right(users.map((userModel) => userModel.toEntity()).toList());
    } catch (error, stackTrace) {
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
    } catch (error, stackTrace) {
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
