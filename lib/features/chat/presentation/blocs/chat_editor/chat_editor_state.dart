part of 'chat_editor_bloc.dart';

@immutable
sealed class ChatEditorState {
  const ChatEditorState({required this.chatMembers});
  final List<User> chatMembers;
}

final class ChatEditorDrafted extends ChatEditorState {
  const ChatEditorDrafted({required super.chatMembers});
}

final class ChatEditorLoaded extends ChatEditorState {
  const ChatEditorLoaded({required super.chatMembers, required this.chatId});
  final String chatId;
}

final class ChatEditorLoading extends ChatEditorState {
  const ChatEditorLoading({required super.chatMembers});
}

final class ChatEditorWaitingForFirstMessage extends ChatEditorState {
  const ChatEditorWaitingForFirstMessage({required super.chatMembers});
}

final class ChatEditorFailure extends ChatEditorState {
  const ChatEditorFailure(this.message, {required super.chatMembers});
  final String message;
}
