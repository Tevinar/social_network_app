import 'package:social_app/features/chat/domain/entities/chat.dart';

/// Domain entity representing one cursor-based slice of the chat feed.
class ChatFeedSlice {
  /// Creates a [ChatFeedSlice].
  const ChatFeedSlice({
    required this.chats,
    required this.nextCursor,
  });

  /// Chats returned in the current slice.
  final List<Chat> chats;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
