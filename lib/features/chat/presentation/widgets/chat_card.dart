import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final Chat chat;
  const ChatCard({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: 20),
      child: Row(
        spacing: 10,
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        chat.members.map((e) => e.name).join(', '),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(chat.lastMessage.updatedAt.toString()),
                  ],
                ),

                Text(
                  chat.lastMessage.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppPallete.greyColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
