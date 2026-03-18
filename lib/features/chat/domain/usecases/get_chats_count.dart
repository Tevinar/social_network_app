import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/usecases/usecase.dart';
import 'package:social_network_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetChatsCount implements UseCase<int, NoParams> {
  final ChatRepository _chatRepository;

  GetChatsCount({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _chatRepository.getChatsCount();
  }
}
