import 'package:bloc_app/core/errors/failures_mapper.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/core/errors/failures.dart';
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
      return Right(users.map((userModel) => userModel.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> getUsersCount() async {
    try {
      final int usersCount = await usersRemoteDataSource.getUsersCount();
      return right(usersCount);
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }
}
