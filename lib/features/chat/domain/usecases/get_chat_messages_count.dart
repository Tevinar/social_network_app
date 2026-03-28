import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

class GetChatMessagesCount implements UseCase<int, String> {
  GetChatMessagesCount({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;
  final ChatMessageRepository _chatMessageRepository;

  @override
  Future<Either<Failure, int>> call(String chatId) {
    return _chatMessageRepository.getChatMessagesCount(chatId);
  }
}
