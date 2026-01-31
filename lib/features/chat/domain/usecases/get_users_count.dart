import 'package:bloc_app/core/errors/failure.dart';
import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/chat/domain/repositories/users_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUsersCount implements UseCase<int, NoParams> {
  final UsersRepository _usersRepository;
  GetUsersCount({required UsersRepository usersRepository})
    : _usersRepository = usersRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _usersRepository.getUsersCount();
  }
}
