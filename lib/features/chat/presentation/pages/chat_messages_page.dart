import 'package:bloc_app/app/session/app_user_cubit.dart';
import 'package:bloc_app/core/common/widgets/loader.dart';
import 'package:bloc_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:bloc_app/features/chat/presentation/blocs/chat_messages/chat_messages_bloc.dart';
import 'package:bloc_app/features/chat/presentation/pages/chat_message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({super.key});

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    loadInitialChatMessagesPage(context.read<ChatEditorBloc>().state);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void loadInitialChatMessagesPage(ChatEditorState state) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatEditorBloc, ChatEditorState>(
      listener: (context, state) {
        loadInitialChatMessagesPage(state);
      },
      builder: (context, chatEditorState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              chatEditorState.chatMembers
                  .where(
                    (member) =>
                        member.id !=
                        (context.read<AppUserCubit>().state as AppUserSignedIn)
                            .user
                            .id,
                  )
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
                        controller: context
                            .read<ChatMessagesBloc>()
                            .scrollController,
                        itemCount:
                            chatMessagesState.chatMessages.length ==
                                chatMessagesState.totalChatMessagesInDatabase
                            ? chatMessagesState.chatMessages.length
                            : chatMessagesState.chatMessages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == chatMessagesState.chatMessages.length) {
                            return const Loader(size: 30);
                          } else {
                            String authorName = chatEditorState.chatMembers
                                .firstWhere(
                                  (member) =>
                                      member.id ==
                                      chatMessagesState
                                          .chatMessages[index]
                                          .authorId,
                                )
                                .name;
                            return ChatMessageCard(
                              chatMessage:
                                  chatMessagesState.chatMessages[index],
                              authorName: authorName,
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
                  return TextField(
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(context, state),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      suffixIcon: IconButton(
                        onPressed: () => _sendMessage(context, state),
                        icon: state is ChatEditorLoading
                            ? const Loader()
                            : const Icon(Icons.send),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
