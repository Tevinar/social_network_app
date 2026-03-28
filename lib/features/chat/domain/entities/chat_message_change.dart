import 'package:social_app/features/chat/domain/entities/chat_message.dart';

sealed class ChatMessageChange {}

class ChatMessageInserted extends ChatMessageChange {
  ChatMessageInserted(this.chatMessage);
  final ChatMessage chatMessage;
}

class ChatMessageUpdated extends ChatMessageChange {
  ChatMessageUpdated(this.chatMessage);
  final ChatMessage chatMessage;
}

class ChatMessageDeleted extends ChatMessageChange {
  ChatMessageDeleted(this.chatMessageId);
  final String chatMessageId;
}
