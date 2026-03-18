import 'package:social_network_app/features/auth/domain/entities/user.dart';
import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/usecases/usecase.dart';
import 'package:social_network_app/features/chat/domain/repositories/users_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUsersPage implements UseCase<List<User>, int> {
  final UsersRepository _usersRepository;
  GetUsersPage({required UsersRepository usersRepository})
    : _usersRepository = usersRepository;

  @override
  Future<Either<Failure, List<User>>> call(int nextPage) {
    return _usersRepository.getUsersPage(nextPage);
  }
}
