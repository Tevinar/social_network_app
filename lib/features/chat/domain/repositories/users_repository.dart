import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

abstract interface class UsersRepository {
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber);

  Future<Either<Failure, int>> getUsersCount();
}
