import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_list_slice.dart';
import 'package:social_app/features/chat/domain/use_cases/create_chat_message_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/get_chat_message_list_slice_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/subscribe_to_chat_message_list_use_case.dart';

part 'chat_message_list_event.dart';
part 'chat_message_list_state.dart';

/// Manages the chat-message list state for one chat.
class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessageListState> {
  /// Creates a [ChatMessagesBloc].
  ChatMessagesBloc({
    required GetChatMessageListSliceUseCase getChatMessageListSlice,
    required SubscribeToChatMessageListUseCase subscribeToChatMessageList,
    required CreateChatMessageUseCase createChatMessage,
  }) : _getChatMessageListSlice = getChatMessageListSlice,
       _subscribeToChatMessageList = subscribeToChatMessageList,
       _createChatMessage = createChatMessage,
       super(
         const ChatMessageListLoading(
           chatId: '',
           chatMessages: [],
           nextCursor: null,
         ),
       ) {
    on<LoadChatMessageListNextSlice>(
      _onLoadChatMessagesNextPage,
      transformer: droppable(),
    );
    on<ChatMessageListChangeReceived>(_onChatMessageChangeReceived);
    on<LoadInitialChatMessageListSlice>(_onLoadInitialChatMessagesPage);
    on<AddChatMessage>(_onAddChatMessage);

    _addListenerToScrollController();
  }

  static const int _pageSize = 20;

  final GetChatMessageListSliceUseCase _getChatMessageListSlice;
  final SubscribeToChatMessageListUseCase _subscribeToChatMessageList;
  final CreateChatMessageUseCase _createChatMessage;

  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Either<Failure, ChatMessageListChange>>?
  _chatMessageChangeSub;

  @override
  Future<void> close() async {
    try {
      await _chatMessageChangeSub?.cancel();
    } finally {
      try {
        _scrollController.dispose();
      } finally {
        await super.close();
      }
    }
  }

  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(const LoadChatMessageListNextSlice());
      }
    });
  }

  Future<void> _addListenerToSubscription(String chatId) async {
    // Cancel previous subscription if exists. This is important to avoid
    // creating multiple subscriptions if LoadInitialChatMessageListSlice
    // is called multiple times for the same chat.
    await _chatMessageChangeSub?.cancel();
    _chatMessageChangeSub =
        _subscribeToChatMessageList(
          SubscribeToChatMessageListParams(chatId: chatId),
        ).listen((event) {
          add(ChatMessageListChangeReceived(event));
        });
  }

  Future<void> _onLoadInitialChatMessagesPage(
    LoadInitialChatMessageListSlice event,
    Emitter<ChatMessageListState> emit,
  ) async {
    await _addListenerToSubscription(event.chatId);

    emit(
      ChatMessageListLoading(
        chatId: event.chatId,
        chatMessages: const [],
        nextCursor: null,
      ),
    );

    add(const LoadChatMessageListNextSlice());
  }

  Future<void> _onAddChatMessage(
    AddChatMessage event,
    Emitter<ChatMessageListState> emit,
  ) async {
    final result = await _createChatMessage(
      CreateChatMessageParams(chatId: event.chatId, content: event.content),
    );

    result.fold(
      (failure) {
        emit(
          ChatMessageListFailure(
            chatId: state.chatId,
            error: failure.message,
            chatMessages: state.chatMessages,
            nextCursor: state.nextCursor,
          ),
        );
      },
      (_) {
        // The server-pushed stream will emit the inserted chat message.
      },
    );
  }

  void _onChatMessageChangeReceived(
    ChatMessageListChangeReceived event,
    Emitter<ChatMessageListState> emit,
  ) {
    event.chatMessageChange.fold(
      (failure) {
        emit(
          ChatMessageListFailure(
            chatId: state.chatId,
            error: failure.message,
            chatMessages: state.chatMessages,
            nextCursor: state.nextCursor,
          ),
        );
      },
      (chatMessageChange) {
        switch (chatMessageChange) {
          case ChatMessageInserted(:final chatId, :final chatMessage):
            if (chatId != state.chatId) {
              return;
            }

            final updatedMessages = _prependChatMessageIfMissing(chatMessage);

            emit(
              state.copyWith(
                chatMessages: updatedMessages,
                nextCursor: state.nextCursor,
              ),
            );
        }
      },
    );
  }

  Future<void> _onLoadChatMessagesNextPage(
    LoadChatMessageListNextSlice event,
    Emitter<ChatMessageListState> emit,
  ) async {
    if (state.chatId.isEmpty) {
      return;
    }

    if (state.chatMessages.isNotEmpty && state.nextCursor == null) {
      return;
    }

    final previousChatId = state.chatId;
    final previousMessages = state.chatMessages;
    final previousCursor = state.nextCursor;

    emit(
      ChatMessageListLoading(
        chatId: previousChatId,
        chatMessages: previousMessages,
        nextCursor: previousCursor,
      ),
    );

    final result = await _getChatMessageListSlice(
      GetChatMessageListSliceParams(
        chatId: previousChatId,
        limit: _pageSize,
        cursor: previousCursor,
      ),
    );

    result.fold(
      (failure) {
        emit(
          ChatMessageListFailure(
            chatId: previousChatId,
            error: failure.message,
            chatMessages: previousMessages,
            nextCursor: previousCursor,
          ),
        );
      },
      (chatMessageListSlice) {
        emit(
          ChatMessageListSuccess(
            chatId: previousChatId,
            chatMessages: _mergeChatMessages(
              existingMessages: previousMessages,
              chatMessageListSlice: chatMessageListSlice,
            ),
            nextCursor: chatMessageListSlice.nextCursor,
          ),
        );
      },
    );
  }

  /// The scroll controller.
  ScrollController get scrollController => _scrollController;

  List<ChatMessage> _mergeChatMessages({
    required List<ChatMessage> existingMessages,
    required ChatMessageListSlice chatMessageListSlice,
  }) {
    return [
      ...existingMessages,
      ...chatMessageListSlice.chatMessages.where(
        (nextMessage) => existingMessages.every(
          (existingMessage) => existingMessage.id != nextMessage.id,
        ),
      ),
    ];
  }

  List<ChatMessage> _prependChatMessageIfMissing(ChatMessage chatMessage) {
    final messageAlreadyExists = state.chatMessages.any(
      (existingMessage) => existingMessage.id == chatMessage.id,
    );

    if (messageAlreadyExists) {
      return state.chatMessages;
    }

    return [
      chatMessage,
      ...state.chatMessages,
    ];
  }
}
