import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Validates chat input data and delegates chat creation to the repository.
class CreateChat implements UseCase<Chat, CreateChatParams> {
  /// Creates a [CreateChat].
  CreateChat({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to create the chat.
  final ChatRepository _chatRepository;

  @override
  /// Validates the first message, then creates the chat if the data is valid.
  Future<Either<Failure, Chat>> call(CreateChatParams params) {
    if (params.firstMessageContent.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('Message cannot be empty')),
      );
    }
    return _chatRepository.createChat(
      params.members,
      params.firstMessageContent,
    );
  }
}

/// Parameters required to create a new chat.
class CreateChatParams {
  /// Creates a [CreateChatParams].
  CreateChatParams({
    required this.members,
    required this.firstMessageContent,
  });

  /// Members who should belong to the created chat.
  final List<UserEntity> members;

  /// First message content sent with the new chat.
  final String firstMessageContent;
}
