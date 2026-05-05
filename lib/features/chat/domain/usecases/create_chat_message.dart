import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

/// A create chat message.
class CreateChatMessage implements UseCase<void, CreateChatMessageParams> {
  /// Creates a [CreateChatMessage].
  CreateChatMessage({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;
  final ChatMessageRepository _chatMessageRepository;

  @override
  Future<Either<Failure, dynamic>> call(CreateChatMessageParams params) {
    if (params.content.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('Message cannot be empty')),
      );
    }
    return _chatMessageRepository.createChatMessage(
      chatId: params.chatId,
      content: params.content,
    );
  }
}

/// A create chat message params.
class CreateChatMessageParams {
  /// Creates a [CreateChatMessageParams].
  CreateChatMessageParams({required this.chatId, required this.content});

  /// The chat id.
  final String chatId;

  /// The content.
  final String content;
}
