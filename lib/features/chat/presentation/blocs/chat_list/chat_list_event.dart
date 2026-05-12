part of 'chat_list_bloc.dart';

@immutable
/// Represents chats event.
sealed class ChatListEvent {
  const ChatListEvent();
}

/// Loads the next cursor-based chat-list slice.
class LoadChatListNextSlice extends ChatListEvent {
  /// Creates a [LoadChatListNextSlice].
  const LoadChatListNextSlice();
}

/// Applies one live chat-list change received from the backend.
final class ChatChangeReceived extends ChatListEvent {
  /// Creates a [ChatChangeReceived].
  const ChatChangeReceived(this.chatChange);

  /// The chat change.
  final Either<Failure, ChatListChange> chatChange;
}
