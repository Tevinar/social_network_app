import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

/// A get chat messages page widget.
class GetChatMessagesPage
    implements UseCase<List<ChatMessage>, GetChatMessagesPageParams> {
  /// Creates a [GetChatMessagesPage].
  GetChatMessagesPage({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;
  final ChatMessageRepository _chatMessageRepository;

  @override
  Future<Either<Failure, List<ChatMessage>>> call(
    /// The params.
    GetChatMessagesPageParams params,
  ) {
    return _chatMessageRepository.getChatMessagesPage(
      params.pageNumber,
      params.chatId,
    );
  }
}

/// A get chat messages page params.
class GetChatMessagesPageParams {
  /// Creates a [GetChatMessagesPageParams].
  GetChatMessagesPageParams({required this.pageNumber, required this.chatId});

  /// The int.
  final int pageNumber;

  /// The chat id.
  final String chatId;
}
