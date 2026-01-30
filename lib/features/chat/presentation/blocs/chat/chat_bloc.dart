import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/usecases/create_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateChat _createChat;

  ChatBloc({required CreateChat createChat})
    : _createChat = createChat,
      super(ChatInitial()) {
    on<ChatEvent>((event, emit) {});
    on<ChatCreate>(_onCreateChat);
  }

  Future<void> _onCreateChat(ChatCreate event, Emitter<ChatState> emit) async {
    final Either<Failure, Chat> res = await _createChat.call(event.chatMembers);

    res.fold(
      (l) => emit(ChatFailure(l.message)),
      (r) => emit(ChatCreateSuccess()),
    );
  }
}
