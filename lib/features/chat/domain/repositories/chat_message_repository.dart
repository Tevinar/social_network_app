import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';

/// A chat message repository.
abstract class ChatMessageRepository {
  /// Gets the chat messages page.
  Future<Either<Failure, List<ChatMessage>>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  );

  /// Gets the chat messages count.
  Future<Either<Failure, int>> getChatMessagesCount(String chatId);

  /// Create chat message.
  Future<Either<Failure, void>> createChatMessage({
    required String chatId,
    required String content,
  });

  /// Returns the watch chat message changes stream.
  Stream<Either<Failure, ChatMessageChange>> watchChatMessageChanges();
}
