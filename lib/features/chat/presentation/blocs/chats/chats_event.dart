part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class LoadChatsNextPage extends ChatsEvent {}

final class ChatChangeReceived extends ChatsEvent {
  final Either<Failure, ChatChange> chatChange;
  ChatChangeReceived(this.chatChange);
}
