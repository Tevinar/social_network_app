import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

class GetChatMessagesPage
    implements UseCase<List<ChatMessage>, GetChatMessagesPageParams> {
  GetChatMessagesPage({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;
  final ChatMessageRepository _chatMessageRepository;

  @override
  Future<Either<Failure, List<ChatMessage>>> call(
    GetChatMessagesPageParams params,
  ) {
    return _chatMessageRepository.getChatMessagesPage(
      params.pageNumber,
      params.chatId,
    );
  }
}

class GetChatMessagesPageParams {
  GetChatMessagesPageParams({required this.pageNumber, required this.chatId});
  final int pageNumber;
  final String chatId;
}
