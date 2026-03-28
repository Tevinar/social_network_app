import 'package:social_app/features/chat/domain/entities/chat.dart';

/// Represents chat change.
sealed class ChatChange {}

/// A chat inserted.
class ChatInserted extends ChatChange {
  /// Creates a [ChatInserted].
  ChatInserted(this.chat);

  /// The chat.
  final Chat chat;
}

/// A chat updated.
class ChatUpdated extends ChatChange {
  /// Creates a [ChatUpdated].
  ChatUpdated(this.chat);

  /// The chat.
  final Chat chat;
}

/// A chat deleted.
class ChatDeleted extends ChatChange {
  /// Creates a [ChatDeleted].
  ChatDeleted(this.chatId);

  /// The chat id.
  final String chatId;
}
