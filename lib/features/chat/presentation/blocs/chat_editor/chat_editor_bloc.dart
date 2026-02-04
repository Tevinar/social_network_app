import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/usecases/create_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'chat_editor_event.dart';
part 'chat_editor_state.dart';

class ChatEditorBloc extends Bloc<ChatEditorEvent, ChatEditorState> {
  final CreateChat _createChat;

  ChatEditorBloc({required CreateChat createChat})
    : _createChat = createChat,
      super(const ChatEditorLoading(chatMembers: [])) {
    on<AddChat>(_onAddChat);
    on<AddChatFirstMessage>(_onAddChatFirstMessage);
    on<SelectChat>(_onSelectChat);
  }

  @override
  void onTransition(Transition<ChatEditorEvent, ChatEditorState> transition) {
    super.onTransition(transition);
  }

  /// On chat addition, wait for the first message to be added to backend
  Future<void> _onAddChat(AddChat event, Emitter<ChatEditorState> emit) async {
    emit(ChatEditorWaitingForFirstMessage(chatMembers: event.chatMembers));
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
        ChatEditorInitial(chatId: chat.id, chatMembers: state.chatMembers),
      ),
    );
  }

  Future<void> _onSelectChat(
    SelectChat event,
    Emitter<ChatEditorState> emit,
  ) async {
    emit(
      ChatEditorInitial(chatId: event.chatId, chatMembers: event.chatMembers),
    );
  }
}
