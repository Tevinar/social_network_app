import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

class GetChatsCount implements UseCase<int, NoParams> {
  GetChatsCount({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;
  final ChatRepository _chatRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _chatRepository.getChatsCount();
  }
}
