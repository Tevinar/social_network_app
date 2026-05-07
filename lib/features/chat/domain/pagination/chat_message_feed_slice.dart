import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// Domain entity representing one cursor-based slice of chat messages.
class ChatMessageFeedSlice {
  /// Creates a [ChatMessageFeedSlice].
  const ChatMessageFeedSlice({
    required this.chatMessages,
    required this.nextCursor,
  });

  /// Messages returned in the current slice.
  final List<ChatMessage> chatMessages;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
