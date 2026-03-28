import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

class CreateChatMessage implements UseCase<void, CreateChatMessageParams> {
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

class CreateChatMessageParams {
  CreateChatMessageParams({required this.chatId, required this.content});
  final String chatId;
  final String content;
}
