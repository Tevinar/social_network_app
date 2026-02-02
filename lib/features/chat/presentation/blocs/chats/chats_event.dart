part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class LoadChatsNextPage extends ChatsEvent {}
