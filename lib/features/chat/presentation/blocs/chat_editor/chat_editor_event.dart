// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_editor_bloc.dart';

@immutable
sealed class ChatEditorEvent {}

class AddChat extends ChatEditorEvent {
  final List<User> chatMembers;
  AddChat({required this.chatMembers});
}

class AddChatFirstMessage extends ChatEditorEvent {
  final List<User> chatMembers;
  final String firstMessageContent;
  AddChatFirstMessage({
    required this.chatMembers,
    required this.firstMessageContent,
  });
}
