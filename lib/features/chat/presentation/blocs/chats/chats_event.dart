part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class LoadChatsNextPage extends ChatsEvent {}

final class ChatChangeReceived extends ChatsEvent {
  ChatChangeReceived(this.chatChange);
  final Either<Failure, ChatChange> chatChange;
}
