import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// Domain entity representing a successful chat write response.
class ChatWriteResult {
  /// Creates a [ChatWriteResult].
  const ChatWriteResult({
    required this.chat,
    required this.chatMessage,
  });

  /// Updated chat returned by the backend.
  final Chat chat;

  /// Newly created message returned by the backend.
  final ChatMessage chatMessage;
}
