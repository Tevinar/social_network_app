import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UsersRepository {
  Future<Either<ServerFailure, List<User>>> getUsersPage(int pageNumber);

  Future<Either<ServerFailure, int>> getUsersCount();
}
