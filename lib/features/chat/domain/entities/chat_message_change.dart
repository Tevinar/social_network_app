import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// Represents chat message change.
sealed class ChatMessageChange {}

/// A chat message inserted.
class ChatMessageInserted extends ChatMessageChange {
  /// Creates a [ChatMessageInserted].
  ChatMessageInserted({required this.chatId, required this.chatMessage});

  /// The chat id.
  final String chatId;

  /// The chat message.
  final ChatMessage chatMessage;
}

/// A chat message updated.
class ChatMessageUpdated extends ChatMessageChange {
  /// Creates a [ChatMessageUpdated].
  ChatMessageUpdated({required this.chatId, required this.chatMessage});

  /// The chat id.
  final String chatId;

  /// The chat message.
  final ChatMessage chatMessage;
}

/// A chat message deleted.
class ChatMessageDeleted extends ChatMessageChange {
  /// Creates a [ChatMessageDeleted].
  ChatMessageDeleted({required this.chatId, required this.chatMessageId});

  /// The chat id.
  final String chatId;

  /// The chat message id.
  final String chatMessageId;
}
