import 'package:social_app/features/chat/domain/entities/chat.dart';

sealed class ChatChange {}

class ChatInserted extends ChatChange {
  final Chat chat;
  ChatInserted(this.chat);
}

class ChatUpdated extends ChatChange {
  final Chat chat;
  ChatUpdated(this.chat);
}

class ChatDeleted extends ChatChange {
  final String chatId;
  ChatDeleted(this.chatId);
}
