import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// A chat.
class Chat {
  /// Creates a [Chat].
  Chat({required this.id, required this.lastMessage, required this.members});

  /// The id.
  final String id;

  /// The last message.
  final ChatMessage lastMessage;

  /// The members.
  final List<UserEntity> members;
}
