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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: _createChatMessagesBloc,
      child: BlocConsumer<ChatEditorBloc, ChatEditorState>(
        listener: _loadInitialChatMessagesPage,
        builder: _buildPage,
      ),
    );
  }

  Widget _buildPage(BuildContext context, ChatEditorState chatEditorState) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chatTitle(chatEditorState)),
      ),
      body: Column(
        children: [
          _buildMessagesSection(chatEditorState),
          BlocBuilder<ChatEditorBloc, ChatEditorState>(
            builder: _buildComposer,
          ),
        ],
      ),
    );
  }

  String _chatTitle(ChatEditorState chatEditorState) {
    return chatEditorState.chatMembers
        .where((member) => member.id != _currentUser.id)
        .map((member) => member.name)
        .join(', ');
  }

  Widget _buildMessagesSection(ChatEditorState chatEditorState) {
    if (chatEditorState is! ChatEditorLoaded) {
      return const Expanded(child: SizedBox());
    }

    return BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
      builder: (context, chatMessagesState) {
        return Flexible(
          child: _buildChatMessagesList(chatEditorState, chatMessagesState),
        );
      },
    );
  }

  Widget _buildChatMessagesList(
    ChatEditorLoaded chatEditorState,
    ChatMessagesState chatMessagesState,
  ) {
    return ListView.builder(
      reverse: true,
      controller: context.read<ChatMessagesBloc>().scrollController,
      itemCount: _messageItemCount(chatMessagesState),
      itemBuilder: (context, index) {
        return _buildChatMessageListItem(
          chatEditorState,
          chatMessagesState,
          index,
        );
      },
    );
  }

  Widget _buildChatMessageListItem(
    ChatEditorLoaded chatEditorState,
    ChatMessagesState chatMessagesState,
    int index,
  ) {
    if (index == chatMessagesState.chatMessages.length) {
      return const Loader(size: 30);
    }

    final currentChatMessage = chatMessagesState.chatMessages[index];

    return Column(
      children: [
        if (_shouldShowDateSeparator(chatMessagesState, index))
          _buildDateSeparator(currentChatMessage.createdAt),
        ChatMessageCard(
          chatMessage: currentChatMessage,
          authorName: _authorName(chatEditorState, currentChatMessage.authorId),
          isMe: currentChatMessage.authorId == _currentUser.id,
        ),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        formatToDay(date),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  int _messageItemCount(ChatMessagesState chatMessagesState) {
    return chatMessagesState.chatMessages.length ==
            chatMessagesState.totalChatMessagesInDatabase
        ? chatMessagesState.chatMessages.length
        : chatMessagesState.chatMessages.length + 1;
  }

  String _authorName(ChatEditorLoaded chatEditorState, String authorId) {
    return chatEditorState.chatMembers
        .firstWhere((member) => member.id == authorId)
        .name;
  }

  bool _shouldShowDateSeparator(
    ChatMessagesState chatMessagesState,
    int index,
  ) {
    if (index == chatMessagesState.chatMessages.length - 1) {
      return true;
    }

    final currentChatMessage = chatMessagesState.chatMessages[index];
    final nextChatMessage = chatMessagesState.chatMessages[index + 1];

    return !_isSameDay(currentChatMessage.createdAt, nextChatMessage.createdAt);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildComposer(BuildContext context, ChatEditorState state) {
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
            _buildSendButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, ChatEditorState state) {
    return IconButton.filled(
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          AppPallete.gradient1,
        ),
      ),
      onPressed: () => _sendMessage(context, state),
      icon: state is ChatEditorLoading
          ? const Loader()
          : const Icon(
              Icons.send,
              color: AppPallete.whiteColor,
            ),
    );
  }

  ChatMessagesBloc _createChatMessagesBloc(BuildContext context) {
    final chatEditorState = context.read<ChatEditorBloc>().state;

    if (chatEditorState is! ChatEditorLoaded) {
      return serviceLocator<ChatMessagesBloc>();
    }

    return serviceLocator<ChatMessagesBloc>()
      ..add(LoadInitialChatMessagesPage(chatEditorState.chatId));
  }

  void _loadInitialChatMessagesPage(
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

    if (messageText.isEmpty) {
      return;
    }

    switch (state) {
      case ChatEditorLoaded():
        _sendLoadedChatMessage(context, state.chatId, messageText);

      case ChatEditorWaitingForFirstMessage():
        _sendFirstChatMessage(context, messageText);

      default:
        break;
    }
  }

  void _sendLoadedChatMessage(
    BuildContext context,
    String chatId,
    String messageText,
  ) {
    context.read<ChatMessagesBloc>().add(
      AddChatMessage(chatId, messageText),
    );
    _messageController.clear();
  }

  void _sendFirstChatMessage(BuildContext context, String messageText) {
    context.read<ChatEditorBloc>().add(
      AddChatFirstMessage(firstMessageContent: messageText),
    );
    _messageController.clear();
  }
}
