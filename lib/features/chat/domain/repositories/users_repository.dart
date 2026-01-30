import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UsersRepository {
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber);

  Future<Either<Failure, int>> getUsersCount();
}
