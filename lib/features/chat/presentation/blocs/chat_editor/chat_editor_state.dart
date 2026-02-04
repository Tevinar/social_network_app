part of 'chat_editor_bloc.dart';

@immutable
sealed class ChatEditorState {
  final List<User> chatMembers;
  const ChatEditorState({required this.chatMembers});
}

final class ChatEditorDrafted extends ChatEditorState {
  const ChatEditorDrafted({required super.chatMembers});
}

final class ChatEditorLoaded extends ChatEditorState {
  final String chatId;
  const ChatEditorLoaded({required super.chatMembers, required this.chatId});
}

final class ChatEditorLoading extends ChatEditorState {
  const ChatEditorLoading({required super.chatMembers});
}

final class ChatEditorWaitingForFirstMessage extends ChatEditorState {
  const ChatEditorWaitingForFirstMessage({required super.chatMembers});
}

final class ChatEditorFailure extends ChatEditorState {
  final String message;
  const ChatEditorFailure(this.message, {required super.chatMembers});
}
