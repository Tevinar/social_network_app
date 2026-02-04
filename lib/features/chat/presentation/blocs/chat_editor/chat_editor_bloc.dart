import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/usecases/create_chat.dart';
import 'package:bloc_app/features/chat/domain/usecases/get_chat_by_members.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'chat_editor_event.dart';
part 'chat_editor_state.dart';

class ChatEditorBloc extends Bloc<ChatEditorEvent, ChatEditorState> {
  final CreateChat _createChat;
  final GetChatByMembers _getChatByMembers;

  ChatEditorBloc({
    required CreateChat createChat,
    required GetChatByMembers getChatByMembers,
  }) : _createChat = createChat,
       _getChatByMembers = getChatByMembers,
       super(const ChatEditorDrafted(chatMembers: [])) {
    on<AddChat>(_onAddChat);
    on<AddChatFirstMessage>(_onAddChatFirstMessage);
    on<SelectChat>(_onSelectChat);
  }

  /// On chat addition, if chat does not exist, wait for the first message to be added to backend
  /// If chat already exists, directly navigate to the chat page
  Future<void> _onAddChat(AddChat event, Emitter<ChatEditorState> emit) async {
    emit(ChatEditorLoading(chatMembers: event.chatMembers));
    final res = await _getChatByMembers.call(
      GetChatByMembersParams(members: event.chatMembers),
    );

    res.fold(
      (failure) => emit(
        ChatEditorFailure(failure.message, chatMembers: event.chatMembers),
      ),
      (chat) {
        if (chat == null) {
          emit(
            ChatEditorWaitingForFirstMessage(chatMembers: event.chatMembers),
          );
        } else {
          emit(
            ChatEditorLoaded(chatId: chat.id, chatMembers: event.chatMembers),
          );
        }
      },
    );
  }

  /// On first message addition, add chat to backend with the first message
  Future<void> _onAddChatFirstMessage(
    AddChatFirstMessage event,
    Emitter<ChatEditorState> emit,
  ) async {
    emit(ChatEditorLoading(chatMembers: state.chatMembers));

    final Either<Failure, Chat> res = await _createChat.call(
      CreateChatParams(
        members: state.chatMembers,
        firstMessageContent: event.firstMessageContent,
      ),
    );

    res.fold(
      (l) => emit(ChatEditorFailure(l.message, chatMembers: state.chatMembers)),
      (chat) => emit(
        ChatEditorLoaded(chatId: chat.id, chatMembers: state.chatMembers),
      ),
    );
  }

  Future<void> _onSelectChat(
    SelectChat event,
    Emitter<ChatEditorState> emit,
  ) async {
    emit(
      ChatEditorLoaded(chatId: event.chatId, chatMembers: event.chatMembers),
    );
  }
}
