part of 'chat_messages_bloc.dart';

@immutable
sealed class ChatMessagesEvent {}

class LoadInitialChatMessagesPage extends ChatMessagesEvent {
  final String chatId;
  LoadInitialChatMessagesPage(this.chatId);
}

class LoadChatMessagesNextPage extends ChatMessagesEvent {}

class AddChatMessage extends ChatMessagesEvent {
  final String chatId;
  final String content;
  AddChatMessage(this.chatId, this.content);
}

final class ChatMessageChangeReceived extends ChatMessagesEvent {
  final Either<Failure, ChatMessageChange> chatMessageChange;
  ChatMessageChangeReceived(this.chatMessageChange);
}
