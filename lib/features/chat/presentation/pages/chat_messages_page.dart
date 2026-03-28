import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/format_date.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_messages/chat_messages_bloc.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_message_card.dart';

/// A chat messages page widget.
class ChatMessagesPage extends StatefulWidget {
  /// Creates a [ChatMessagesPage].
  const ChatMessagesPage({super.key});

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  late final TextEditingController _messageController;
  late final User _currentUser;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _currentUser = (context.read<AppUserCubit>().state as AppUserSignedIn).user;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void loadInitialChatMessagesPage(
    BuildContext context,
    ChatEditorState state,
  ) {
    if (state is ChatEditorLoaded) {
      context.read<ChatMessagesBloc>().add(
        LoadInitialChatMessagesPage(state.chatId),
      );
    }
  }

  void _sendMessage(BuildContext context, ChatEditorState state) {
    final messageText = _messageController.text.trim();
    if (state is ChatEditorLoaded) {
      context.read<ChatMessagesBloc>().add(
        AddChatMessage(state.chatId, messageText),
      );
      _messageController.clear();
    } else if (state is ChatEditorWaitingForFirstMessage) {
      final messageText = _messageController.text.trim();
      if (messageText.isNotEmpty) {
        // Dispatch an event to send the message
        context.read<ChatEditorBloc>().add(
          AddChatFirstMessage(firstMessageContent: messageText),
        );
        _messageController.clear();
      }
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final chatEditorState = context.read<ChatEditorBloc>().state;

        if (chatEditorState is! ChatEditorLoaded) {
          return serviceLocator<ChatMessagesBloc>();
        } else {
          return serviceLocator<ChatMessagesBloc>()
            ..add(LoadInitialChatMessagesPage(chatEditorState.chatId));
        }
      },

      child: BlocConsumer<ChatEditorBloc, ChatEditorState>(
        listener: loadInitialChatMessagesPage,
        builder: (context, chatEditorState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                chatEditorState.chatMembers
                    .where((member) => member.id != _currentUser.id)
                    .map((member) => member.name)
                    .join(', '),
              ),
            ),
            body: Column(
              children: [
                if (chatEditorState is ChatEditorLoaded)
                  BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
                    builder: (context, chatMessagesState) {
                      return Flexible(
                        child: ListView.builder(
                          reverse: true,
                          controller: context
                              .read<ChatMessagesBloc>()
                              .scrollController,
                          itemCount:
                              chatMessagesState.chatMessages.length ==
                                  chatMessagesState.totalChatMessagesInDatabase
                              ? chatMessagesState.chatMessages.length
                              : chatMessagesState.chatMessages.length + 1,
                          itemBuilder: (context, index) {
                            if (index ==
                                chatMessagesState.chatMessages.length) {
                              return const Loader(size: 30);
                            } else {
                              final authorName = chatEditorState.chatMembers
                                  .firstWhere(
                                    (member) =>
                                        member.id ==
                                        chatMessagesState
                                            .chatMessages[index]
                                            .authorId,
                                  )
                                  .name;
                              final currentChatMessage =
                                  chatMessagesState.chatMessages[index];
                              final showDateSeparator =
                                  index ==
                                      chatMessagesState.chatMessages.length -
                                          1 ||
                                  !isSameDay(
                                    currentChatMessage.createdAt,
                                    chatMessagesState
                                        .chatMessages[index + 1]
                                        .createdAt,
                                  );
                              return Column(
                                children: [
                                  if (showDateSeparator)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        formatToDay(
                                          currentChatMessage.createdAt,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ChatMessageCard(
                                    chatMessage: currentChatMessage,
                                    authorName: authorName,
                                    isMe:
                                        currentChatMessage.authorId ==
                                        _currentUser.id,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      );
                    },
                  )
                else
                  const Expanded(child: SizedBox()),
                BlocBuilder<ChatEditorBloc, ChatEditorState>(
                  builder: (context, state) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: TextField(
                                minLines: 1,
                                maxLines: 6,
                                textInputAction: TextInputAction.newline,
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                            IconButton.filled(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  AppPallete.gradient1,
                                ),
                              ),
                              onPressed: () =>
                                  _messageController.value.text.isEmpty
                                  ? {}
                                  : _sendMessage(context, state),
                              icon: state is ChatEditorLoading
                                  ? const Loader()
                                  : const Icon(
                                      Icons.send,
                                      color: AppPallete.whiteColor,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
