part of 'chat_messages_bloc.dart';

@immutable
/// Represents chat messages event.
sealed class ChatMessagesEvent {}

/// A load initial chat messages page widget.
class LoadInitialChatMessagesPage extends ChatMessagesEvent {
  /// Creates a [LoadInitialChatMessagesPage].
  LoadInitialChatMessagesPage(this.chatId);

  /// The chat id.
  final String chatId;
}

/// A load chat messages next page widget.
class LoadChatMessagesNextPage extends ChatMessagesEvent {}

/// An add chat message.
class AddChatMessage extends ChatMessagesEvent {
  /// Creates a [AddChatMessage].
  AddChatMessage(this.chatId, this.content);

  /// The chat id.
  final String chatId;

  /// The content.
  final String content;
}

/// A chat message change received.
final class ChatMessageChangeReceived extends ChatMessagesEvent {
  /// Creates a [ChatMessageChangeReceived].
  ChatMessageChangeReceived(this.chatMessageChange);

  /// The chat message change.
  final Either<Failure, ChatMessageChange> chatMessageChange;
}
