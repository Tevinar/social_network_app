// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatCreate extends ChatEvent {
  final List<User> chatMembers;
  ChatCreate({required this.chatMembers});
}
