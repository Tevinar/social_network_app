import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';

/// Domain entity representing one chat message.
class ChatMessage {
  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Stable message identifier.
  final String id;

  /// Identifier of the chat that owns this message.
  final String chatId;

  /// Message author when still available.
  final ChatUserSummary? author;

  /// Text content sent in the message.
  final String content;

  /// Timestamp at which the message was created.
  final DateTime createdAt;

  /// Timestamp of the latest message update.
  final DateTime updatedAt;
}
