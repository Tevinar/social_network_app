import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

/// An users repository.
abstract interface class UsersRepository {
  /// Gets the users page.
  Future<Either<Failure, List<User>>> getUsersPage(int pageNumber);

  /// Gets the users count.
  Future<Either<Failure, int>> getUsersCount();
}
