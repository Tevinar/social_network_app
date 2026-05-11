part of 'chat_message_list_bloc.dart';

@immutable
/// Represents chat message list events.
sealed class ChatMessagesEvent {
  const ChatMessagesEvent();
}

/// Loads the first message slice for a chat.
class LoadInitialChatMessageListSlice extends ChatMessagesEvent {
  /// Creates a [LoadInitialChatMessageListSlice].
  const LoadInitialChatMessageListSlice(this.chatId);

  /// Identifier of the chat to load.
  final String chatId;
}

/// Loads the next cursor-based message slice.
class LoadChatMessageListNextSlice extends ChatMessagesEvent {
  /// Creates a [LoadChatMessageListNextSlice].
  const LoadChatMessageListNextSlice();
}

/// Creates one new message in the current chat.
class AddChatMessage extends ChatMessagesEvent {
  /// Creates an [AddChatMessage].
  const AddChatMessage(this.chatId, this.content);

  /// Identifier of the chat that should receive the new message.
  final String chatId;

  /// Message content to send.
  final String content;
}

/// Applies one live chat-message change received from the backend.
final class ChatMessageListChangeReceived extends ChatMessagesEvent {
  /// Creates a [ChatMessageListChangeReceived].
  const ChatMessageListChangeReceived(this.chatMessageChange);

  /// The chat-message change payload.
  final Either<Failure, ChatMessageListChange> chatMessageChange;
}

/// Adds the first chat message locally before server-pushed sync arrives.
class AddManuallyChatFirstMessage extends ChatMessagesEvent {
  /// Creates an [AddManuallyChatFirstMessage].
  const AddManuallyChatFirstMessage(this.chatMessage);

  /// The first chat message to insert into the current message list.
  final ChatMessage chatMessage;
}
