import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failure_messages.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/results/chat_write_result.dart';

/// Validates chat creation input and delegates the write to the repository.
class CreateChatUseCase implements UseCase<ChatWriteResult, CreateChatParams> {
  /// Creates a [CreateChatUseCase].
  CreateChatUseCase({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to create chats.
  final ChatRepository _chatRepository;

  @override
  /// Validates the first message and selected members, then creates the chat.
  Future<Either<Failure, ChatWriteResult>> call(CreateChatParams params) {
    if (params.memberIds.isEmpty) {
      appLogger.debug(
        'Validation failed in CreateChatUseCase: no members selected',
      );
      return Future.value(
        left(
          const ValidationFailure(ChatFailureMessages.memberSelectionRequired),
        ),
      );
    }
    if (params.firstMessageContent.trim().isEmpty) {
      appLogger.debug(
        'Validation failed in CreateChatUseCase: first message content is '
        'empty',
      );
      return Future.value(
        left(
          const ValidationFailure(
            ChatFailureMessages.firstMessageContentRequired,
          ),
        ),
      );
    }

    return _chatRepository.createChat(
      memberIds: params.memberIds,
      firstMessageContent: params.firstMessageContent,
    );
  }
}

/// Parameters required to create one new chat.
class CreateChatParams {
  /// Creates a [CreateChatParams].
  const CreateChatParams({
    required this.memberIds,
    required this.firstMessageContent,
  });

  /// Selected member identifiers, excluding the current user.
  final List<String> memberIds;

  /// Content of the first message that starts the chat.
  final String firstMessageContent;
}
