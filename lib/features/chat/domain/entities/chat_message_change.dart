import 'package:bloc_app/features/chat/domain/entities/chat_message.dart';

sealed class ChatMessageChange {}

class ChatMessageInserted extends ChatMessageChange {
  final ChatMessage chatMessage;
  ChatMessageInserted(this.chatMessage);
}

class ChatMessageUpdated extends ChatMessageChange {
  final ChatMessage chatMessage;
  ChatMessageUpdated(this.chatMessage);
}

class ChatMessageDeleted extends ChatMessageChange {
  final String chatMessageId;
  ChatMessageDeleted(this.chatMessageId);
}
