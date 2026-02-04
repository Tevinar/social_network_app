import 'package:bloc_app/app/router/routes/routes.dart';
import 'package:bloc_app/app/session/app_user_cubit.dart';
import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCard extends StatelessWidget {
  final Chat chat;
  const ChatCard({super.key, required this.chat});

  String computeChatMembersNames(BuildContext context) {
    final List<User> chatMembersWithoutCurrentUser = chat.members
        .where(
          (member) =>
              member.id !=
              (context.read<AppUserCubit>().state as AppUserSignedIn).user.id,
        )
        .toList();

    return chatMembersWithoutCurrentUser
        .map((member) => member.name)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<ChatEditorBloc>().add(
          SelectChat(chatId: chat.id, chatMembers: chat.members),
        );
        const ChatMessagesPageRoute().push(context);
      },
      child: Padding(
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
                          computeChatMembersNames(context),
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
      ),
    );
  }
}
