import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/usecases/usecase.dart';
import 'package:social_network_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetChatMessagesCount implements UseCase<int, String> {
  final ChatMessageRepository _chatMessageRepository;

  GetChatMessagesCount({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;

  @override
  Future<Either<Failure, int>> call(String chatId) {
    return _chatMessageRepository.getChatMessagesCount(chatId);
  }
}
