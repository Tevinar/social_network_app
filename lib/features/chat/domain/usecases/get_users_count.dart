import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/repositories/users_repository.dart';

/// A get users count.
class GetUsersCount implements UseCase<int, NoParams> {
  /// Creates a [GetUsersCount].
  GetUsersCount({required UsersRepository usersRepository})
    : _usersRepository = usersRepository;
  final UsersRepository _usersRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _usersRepository.getUsersCount();
  }
}
