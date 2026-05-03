import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_cases/use_case.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

/// A get chat messages count.
class GetChatMessagesCount implements UseCase<int, String> {
  /// Creates a [GetChatMessagesCount].
  GetChatMessagesCount({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;
  final ChatMessageRepository _chatMessageRepository;

  @override
  Future<Either<Failure, int>> call(String chatId) {
    return _chatMessageRepository.getChatMessagesCount(chatId);
  }
}
