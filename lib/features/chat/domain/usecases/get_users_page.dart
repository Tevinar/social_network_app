import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/repositories/users_repository.dart';

/// A get users page widget.
class GetUsersPage implements UseCase<List<User>, int> {
  /// Creates a [GetUsersPage].
  GetUsersPage({required UsersRepository usersRepository})
    : _usersRepository = usersRepository;
  final UsersRepository _usersRepository;

  @override
  Future<Either<Failure, List<User>>> call(int nextPage) {
    return _usersRepository.getUsersPage(nextPage);
  }
}
