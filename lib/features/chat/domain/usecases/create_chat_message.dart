import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateChatMessage implements UseCase<void, CreateChatMessageParams> {
  final ChatMessageRepository _chatMessageRepository;

  CreateChatMessage({required ChatMessageRepository chatMessageRepository})
    : _chatMessageRepository = chatMessageRepository;

  @override
  Future<Either<Failure, dynamic>> call(params) {
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
