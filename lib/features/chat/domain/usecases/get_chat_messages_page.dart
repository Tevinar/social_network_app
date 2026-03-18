import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetChatMessagesPage
    implements UseCase<List<ChatMessage>, GetChatMessagesPageParams> {
  final ChatMessageRepository _chatMessageRepository;
  GetChatMessagesPage({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;

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
  final int pageNumber;
  final String chatId;

  GetChatMessagesPageParams({required this.pageNumber, required this.chatId});
}
