import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/domain/entities/chat_message.dart';
import 'package:bloc_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChatMessageRepository {
  Future<Either<Failure, List<ChatMessage>>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  );

  Future<Either<Failure, int>> getChatMessagesCount(String chatId);

  Future<Either<Failure, void>> createChatMessage({
    required String chatId,
    required String content,
  });

  Stream<Either<Failure, ChatMessageChange>> watchChatMessageChanges();
}
