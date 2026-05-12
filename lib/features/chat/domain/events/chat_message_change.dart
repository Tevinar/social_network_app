import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// Base type for realtime changes affecting chat messages.
sealed class ChatMessageListChange {
  /// Creates a [ChatMessageListChange].
  const ChatMessageListChange();
}

/// Realtime event emitted when one message is inserted in a chat.
class ChatMessageInserted extends ChatMessageListChange {
  /// Creates a [ChatMessageInserted].
  const ChatMessageInserted({
    required this.chatId,
    required this.chatMessage,
  });

  /// Identifier of the chat that owns the inserted message.
  final String chatId;

  /// Inserted message payload.
  final ChatMessage chatMessage;
}
