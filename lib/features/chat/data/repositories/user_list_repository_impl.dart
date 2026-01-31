import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:bloc_app/features/chat/domain/repositories/users_repository.dart';
import 'package:fpdart/fpdart.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRemoteDataSource usersRemoteDataSource;
  UsersRepositoryImpl({required this.usersRemoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber) async {
    try {
      final users = await usersRemoteDataSource.getUsersPage(pageNumber);
      return Right(users);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on ArgumentError catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getUsersCount() async {
    try {
      final int usersCount = await usersRemoteDataSource.getUsersCount();
      return right(usersCount);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
