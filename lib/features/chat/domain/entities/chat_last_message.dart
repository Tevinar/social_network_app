import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';

/// Domain entity representing the latest message preview shown for one chat.
class ChatLastMessage {
  /// Creates a [ChatLastMessage].
  const ChatLastMessage({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  /// Stable message identifier.
  final String id;

  /// Message author when still available.
  final ChatUserSummary? author;

  /// Preview content shown in chat lists.
  final String content;

  /// Message creation timestamp.
  final DateTime createdAt;
}
