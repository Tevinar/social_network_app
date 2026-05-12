import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failure_messages.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/results/chat_write_result.dart';

/// Validates chat-message input and delegates the write to the repository.
class CreateChatMessageUseCase
    implements UseCase<ChatWriteResult, CreateChatMessageParams> {
  /// Creates a [CreateChatMessageUseCase].
  CreateChatMessageUseCase({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to create chat messages.
  final ChatRepository _chatRepository;

  @override
  /// Validates the message content, then creates the message.
  Future<Either<Failure, ChatWriteResult>> call(
    CreateChatMessageParams params,
  ) {
    if (params.content.trim().isEmpty) {
      return Future.value(
        left(
          const ValidationFailure(ChatFailureMessages.messageContentRequired),
        ),
      );
    }

    return _chatRepository.createChatMessage(
      chatId: params.chatId,
      content: params.content,
    );
  }
}

/// Parameters required to create one chat message.
class CreateChatMessageParams {
  /// Creates a [CreateChatMessageParams].
  const CreateChatMessageParams({
    required this.chatId,
    required this.content,
  });

  /// Identifier of the chat that should receive the new message.
  final String chatId;

  /// Message content to send.
  final String content;
}
