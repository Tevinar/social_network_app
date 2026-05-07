import 'package:social_app/features/chat/domain/entities/chat.dart';

/// Base type for realtime changes affecting the chat feed.
sealed class ChatChange {
  /// Creates a [ChatChange].
  const ChatChange();
}

/// Realtime event emitted when one chat becomes newly visible in the feed.
class ChatInserted extends ChatChange {
  /// Creates a [ChatInserted].
  const ChatInserted(this.chat);

  /// Inserted chat payload.
  final Chat chat;
}

/// Realtime event emitted when one visible chat changes.
class ChatUpdated extends ChatChange {
  /// Creates a [ChatUpdated].
  const ChatUpdated(this.chat);

  /// Updated chat payload.
  final Chat chat;
}
