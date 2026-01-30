import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/features/chat/domain/repositories/users_repository.dart';
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
