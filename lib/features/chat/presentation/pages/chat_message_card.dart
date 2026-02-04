import 'package:bloc_app/features/chat/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';

class ChatMessageCard extends StatelessWidget {
  final ChatMessage chatMessage;
  final String authorName;

  const ChatMessageCard({
    super.key,
    required this.chatMessage,
    required this.authorName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(authorName),
      subtitle: Text(chatMessage.content),
      trailing: Text(
        '${chatMessage.createdAt.hour.toString().padLeft(2, '0')}:${chatMessage.createdAt.minute.toString().padLeft(2, '0')}',
      ),
    );
  }
}
