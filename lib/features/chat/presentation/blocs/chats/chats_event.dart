part of 'chats_bloc.dart';

@immutable
/// Represents chats event.
sealed class ChatsEvent {}

/// A load chats next page widget.
class LoadChatsNextPage extends ChatsEvent {}

/// A chat change received.
final class ChatChangeReceived extends ChatsEvent {
  /// Creates a [ChatChangeReceived].
  ChatChangeReceived(this.chatChange);

  /// The chat change.
  final Either<Failure, ChatChange> chatChange;
}
