import 'package:social_app/features/chat/domain/entities/chat.dart';

/// Base type for realtime changes affecting the chat list.
sealed class ChatListChange {
  /// Creates a [ChatListChange].
  const ChatListChange();
}

/// Realtime event emitted when one chat becomes newly visible in the list.
class ChatInserted extends ChatListChange {
  /// Creates a [ChatInserted].
  const ChatInserted(this.chat);

  /// Inserted chat payload.
  final Chat chat;
}

/// Realtime event emitted when one visible chat changes.
class ChatUpdated extends ChatListChange {
  /// Creates a [ChatUpdated].
  const ChatUpdated(this.chat);

  /// Updated chat payload.
  final Chat chat;
}
