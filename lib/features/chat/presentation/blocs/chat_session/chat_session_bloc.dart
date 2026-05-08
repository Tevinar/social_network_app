import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/domain/usecases/create_chat.dart';
import 'package:social_app/features/chat/domain/usecases/'
    'get_chat_by_members.dart';

part 'chat_session_event.dart';
part 'chat_session_state.dart';

/// A chat editor bloc.
class ChatEditorBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  /// Creates a [ChatEditorBloc].
  ChatEditorBloc({
    required CreateChat createChat,
    required GetChatByMembers getChatByMembers,
  }) : _createChat = createChat,
       _getChatByMembers = getChatByMembers,
       super(const ChatSessionDrafted(chatMembers: [])) {
    on<AddChat>(_onAddChat);
    on<AddChatFirstMessage>(_onAddChatFirstMessage);
    on<SelectChat>(_onSelectChat);
  }
  final CreateChat _createChat;
  final GetChatByMembers _getChatByMembers;

  /// When no chat exists yet, wait for the first backend message.
  /// If one already exists, navigate directly to the chat page.
  Future<void> _onAddChat(AddChat event, Emitter<ChatSessionState> emit) async {
    emit(ChatSessionLoading(chatMembers: state.chatMembers));
    final res = await _getChatByMembers.call(
      GetChatByMembersParams(memberIds: event.chatMemberIds),
    );

    res.fold(
      (failure) => emit(
        ChatSessionFailure(failure.message, chatMembers: state.chatMembers),
      ),
      (chat) {
        if (chat == null) {
          emit(
            ChatSessionWaitingForFirstMessage(chatMembers: state.chatMembers),
          );
        } else {
          emit(
            ChatSessionLoaded(chatId: chat.id, chatMembers: chat.members),
          );
        }
      },
    );
  }

  /// On first message addition, add chat to backend with the first message
  Future<void> _onAddChatFirstMessage(
    AddChatFirstMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(ChatSessionLoading(chatMembers: state.chatMembers));

    final res = await _createChat.call(
      CreateChatParams(
        memberIds: state.chatMembers.map((m) => m.id).toList(),
        firstMessageContent: event.firstMessageContent,
      ),
    );

    res.fold(
      (failure) => emit(
        ChatSessionFailure(failure.message, chatMembers: state.chatMembers),
      ),
      (chatWriteResult) => emit(
        ChatSessionNewlyCreated(
          chatId: chatWriteResult.chat.id,
          chatMembers: chatWriteResult.chat.members,
          chatFirstMessage: chatWriteResult.chatMessage,
        ),
      ),
    );
  }

  Future<void> _onSelectChat(
    SelectChat event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(
      ChatSessionLoaded(chatId: event.chatId, chatMembers: event.chatMembers),
    );
  }
}
