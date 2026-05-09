import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/cubits/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_message_list/chat_message_list_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_session/chat_session_bloc.dart';
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
      child: BlocConsumer<ChatEditorBloc, ChatSessionState>(
        listener: _loadInitialChatMessagesPage,
        builder: _buildPage,
      ),
    );
  }

  Widget _buildPage(BuildContext context, ChatSessionState chatEditorState) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chatTitle(chatEditorState)),
      ),
      body: Column(
        children: [
          _buildMessagesSection(chatEditorState),
          BlocBuilder<ChatEditorBloc, ChatSessionState>(
            builder: _buildComposer,
          ),
        ],
      ),
    );
  }

  String _chatTitle(ChatSessionState chatEditorState) {
    return chatEditorState.chatMembers
        .where((member) => member.id != _currentUser.id)
        .map((member) => member.name)
        .join(', ');
  }

  Widget _buildMessagesSection(ChatSessionState chatEditorState) {
    if (chatEditorState is! ChatSessionLoaded) {
      return const Expanded(child: SizedBox());
    }

    return Expanded(
      child: BlocBuilder<ChatMessagesBloc, ChatMessageListState>(
        builder: (context, chatMessagesState) {
          return _buildChatMessagesList(
            context,
            chatEditorState,
            chatMessagesState,
          );
        },
      ),
    );
  }

  Widget _buildChatMessagesList(
    BuildContext context,
    ChatSessionLoaded chatEditorState,
    ChatMessageListState chatMessagesState,
  ) {
    return ListView.builder(
      reverse: true,
      controller: context.read<ChatMessagesBloc>().scrollController,
      itemCount: _messageItemCount(chatMessagesState),
      itemBuilder: (context, index) {
        return _buildChatMessageListItem(
          chatMessagesState,
          index,
        );
      },
    );
  }

  Widget _buildChatMessageListItem(
    ChatMessageListState chatMessagesState,
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
          authorName: _authorName(currentChatMessage),
          isMe: currentChatMessage.author?.id == _currentUser.id,
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

  int _messageItemCount(ChatMessageListState chatMessagesState) {
    return chatMessagesState.nextCursor == null
        ? chatMessagesState.chatMessages.length
        : chatMessagesState.chatMessages.length + 1;
  }

  String _authorName(ChatMessage chatMessage) {
    return chatMessage.author?.name ?? 'Unknown user';
  }

  bool _shouldShowDateSeparator(
    ChatMessageListState chatMessagesState,
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

  Widget _buildComposer(BuildContext context, ChatSessionState state) {
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

  Widget _buildSendButton(BuildContext context, ChatSessionState state) {
    return IconButton.filled(
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          AppPallete.gradient1,
        ),
      ),
      onPressed: () => _sendMessage(context, state),
      icon: state is ChatSessionLoading
          ? const Loader()
          : const Icon(
              Icons.send,
              color: AppPallete.whiteColor,
            ),
    );
  }

  ChatMessagesBloc _createChatMessagesBloc(BuildContext context) {
    final chatEditorState = context.read<ChatEditorBloc>().state;

    if (chatEditorState is! ChatSessionLoaded) {
      return serviceLocator<ChatMessagesBloc>();
    }

    return serviceLocator<ChatMessagesBloc>()..add(
      LoadInitialChatMessageListSlice(chatEditorState.chatId),
    );
  }

  void _loadInitialChatMessagesPage(
    BuildContext context,
    ChatSessionState state,
  ) {
    if (state is ChatSessionLoaded) {
      context.read<ChatMessagesBloc>().add(
        LoadInitialChatMessageListSlice(state.chatId),
      );
    }
  }

  void _sendMessage(BuildContext context, ChatSessionState state) {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty) {
      return;
    }

    switch (state) {
      case ChatSessionLoaded():
        _sendLoadedChatMessage(context, state.chatId, messageText);

      case ChatSessionWaitingForFirstMessage():
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
