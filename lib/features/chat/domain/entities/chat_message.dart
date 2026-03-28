/// Domain entity representing a message sent inside a chat.
class ChatMessage {
  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique message identifier.
  final String id;

  /// Identifier of the user who authored the message.
  final String authorId;

  /// Message text displayed in the conversation.
  final String content;

  /// Timestamp of the initial message creation.
  final DateTime createdAt;

  /// Timestamp of the latest message update.
  final DateTime updatedAt;
}
