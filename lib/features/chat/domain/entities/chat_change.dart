import 'package:social_app/features/chat/domain/entities/chat.dart';

sealed class ChatChange {}

class ChatInserted extends ChatChange {
  ChatInserted(this.chat);
  final Chat chat;
}

class ChatUpdated extends ChatChange {
  ChatUpdated(this.chat);
  final Chat chat;
}

class ChatDeleted extends ChatChange {
  ChatDeleted(this.chatId);
  final String chatId;
}
