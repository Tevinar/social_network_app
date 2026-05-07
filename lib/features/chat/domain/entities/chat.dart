import 'package:social_app/features/chat/domain/entities/chat_last_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';

/// Domain entity representing one chat conversation.
class Chat {
  /// Creates a [Chat].
  const Chat({
    required this.id,
    required this.members,
    required this.lastMessage,
  });

  /// Stable chat identifier.
  final String id;

  /// Public chat members visible in the UI.
  final List<ChatUserSummary> members;

  /// Latest message preview associated with the chat.
  final ChatLastMessage lastMessage;
}
