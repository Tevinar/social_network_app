import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/features/chat/domain/repositories/user_list_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUsersByPage implements UseCase<List<User>, int> {
  final UserListRepository _userListRepository;
  GetUsersByPage({required UserListRepository userListRepository})
    : _userListRepository = userListRepository;

  @override
  Future<Either<Failure, List<User>>> call(int nextPage) {
    return _userListRepository.getUsersByPage(nextPage);
  }
}
