import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/format_date.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';

class ChatMessageCard extends StatelessWidget {
  const ChatMessageCard({
    required this.isMe,
    required this.chatMessage,
    required this.authorName,
    super.key,
  });
  final ChatMessage chatMessage;
  final String authorName;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppPallete.gradient1 : AppPallete.borderColor;

    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    final borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(16) : Radius.zero,
      topRight: isMe ? Radius.zero : const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe &&
                      context.read<ChatEditorBloc>().state.chatMembers.length >
                          2)
                    Text(
                      authorName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chatMessage.content,
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        formatToHour(chatMessage.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPallete.greyWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
