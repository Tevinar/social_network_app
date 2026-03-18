import 'package:social_network_app/core/errors/failures_mapper.dart';
import 'package:social_network_app/core/logging/app_logger.dart';
import 'package:social_network_app/features/auth/domain/entities/user.dart';
import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:social_network_app/features/chat/domain/repositories/users_repository.dart';
import 'package:fpdart/fpdart.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRemoteDataSource usersRemoteDataSource;
  UsersRepositoryImpl({required this.usersRemoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber) async {
    try {
      final users = await usersRemoteDataSource.getUsersPage(pageNumber);
      return Right(users.map((userModel) => userModel.toEntity()).toList());
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to get users page',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, int>> getUsersCount() async {
    try {
      final int usersCount = await usersRemoteDataSource.getUsersCount();
      return right(usersCount);
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to get users count',
        error: error,
        stackTrace: stackTrace,
      );
      return left(mapExceptionToFailure(error));
    }
  }
}
