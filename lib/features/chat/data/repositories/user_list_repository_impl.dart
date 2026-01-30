import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/features/chat/data/data_sources/user_list_remote_data_source.dart';
import 'package:bloc_app/features/chat/domain/repositories/user_list_repository.dart';
import 'package:fpdart/src/either.dart';

class UserListRepositoryImpl implements UserListRepository {
  UserListRemoteDataSource userListRemoteDataSource;
  UserListRepositoryImpl({required this.userListRemoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsersByPage(int pageNumber) async {
    try {
      final users = await userListRemoteDataSource.getUsersByPage(pageNumber);
      return Right(users);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on ArgumentError catch (e) {
      return Left(Failure(e.message));
    }
  }
}
