import 'package:social_network_app/features/auth/domain/entities/user.dart';
import 'package:social_network_app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UsersRepository {
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber);

  Future<Either<Failure, int>> getUsersCount();
}
