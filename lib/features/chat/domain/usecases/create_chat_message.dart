import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/usecases/usecase.dart';
import 'package:social_network_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateChatMessage implements UseCase<void, CreateChatMessageParams> {
  final ChatMessageRepository _chatMessageRepository;

  CreateChatMessage({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;

  @override
  Future<Either<Failure, dynamic>> call(params) {
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
  final String chatId;
  final String content;

  CreateChatMessageParams({required this.chatId, required this.content});
}
