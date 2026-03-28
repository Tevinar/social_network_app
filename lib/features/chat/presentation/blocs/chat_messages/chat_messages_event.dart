part of 'chat_messages_bloc.dart';

@immutable
sealed class ChatMessagesEvent {}

class LoadInitialChatMessagesPage extends ChatMessagesEvent {
  LoadInitialChatMessagesPage(this.chatId);
  final String chatId;
}

class LoadChatMessagesNextPage extends ChatMessagesEvent {}

class AddChatMessage extends ChatMessagesEvent {
  AddChatMessage(this.chatId, this.content);
  final String chatId;
  final String content;
}

final class ChatMessageChangeReceived extends ChatMessagesEvent {
  ChatMessageChangeReceived(this.chatMessageChange);
  final Either<Failure, ChatMessageChange> chatMessageChange;
}
