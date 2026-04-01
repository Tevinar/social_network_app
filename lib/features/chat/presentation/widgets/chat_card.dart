import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/format_date.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';

/// A chat card widget.
class ChatCard extends StatelessWidget {
  /// Creates a [ChatCard].
  const ChatCard({required this.chat, super.key});

  /// The chat.
  final Chat chat;

  /// The compute chat members names.
  String computeChatMembersNames(BuildContext context) {
    final chatMembersWithoutCurrentUser = chat.members
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
  /// The build.
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        context.read<ChatEditorBloc>().add(
          SelectChat(chatId: chat.id, chatMembers: chat.members),
        );
        await const ChatMessagesPageRoute().push<void>(context);
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
                      Text(
                        isSameDay(chat.lastMessage.updatedAt, DateTime.now())
                            ? formatToHour(chat.lastMessage.updatedAt)
                            : formatToDay(chat.lastMessage.updatedAt),
                      ),
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
