import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/core/errors/exceptions.dart';
import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:bloc_app/features/chat/domain/repositories/users_repository.dart';
import 'package:fpdart/fpdart.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRemoteDataSource usersRemoteDataSource;
  UsersRepositoryImpl({required this.usersRemoteDataSource});

  @override
  Future<Either<ServerFailure, List<User>>> getUsersPage(int pageNumber) async {
    try {
      final users = await usersRemoteDataSource.getUsersPage(pageNumber);
      return Right(users.map((userModel) => userModel.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ArgumentError catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<ServerFailure, int>> getUsersCount() async {
    try {
      final int usersCount = await usersRemoteDataSource.getUsersCount();
      return right(usersCount);
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }
}
