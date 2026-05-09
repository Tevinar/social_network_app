import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_list_slice.dart';
import 'package:social_app/features/chat/domain/use_cases/get_chat_list_slice_use_case.dart';
import 'package:social_app/features/chat/domain/use_cases/subscribe_to_chat_list_use_case.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

/// Manages the chat list state, including cursor pagination and live updates.
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  /// Creates a [ChatListBloc].
  ChatListBloc({
    required GetChatListSliceUseCase getChatListSlice,
    required SubscribeToChatListUseCase subscribeToChatList,
  }) : _getChatListSlice = getChatListSlice,
       _subscribeToChatList = subscribeToChatList,
       super(
         const ChatListLoading(
           chats: [],
           nextCursor: null,
         ),
       ) {
    on<LoadChatListNextSlice>(
      _onLoadChatListNextSlice,
      transformer: droppable(),
    );
    on<ChatChangeReceived>(_onChatChangeReceived);

    _addListenerToScrollController();
    _addListenerToSubscription();

    add(const LoadChatListNextSlice());
  }

  static const int _pageSize = 20;

  final GetChatListSliceUseCase _getChatListSlice;
  final SubscribeToChatListUseCase _subscribeToChatList;

  final ScrollController _scrollController = ScrollController();

  late final StreamSubscription<Either<Failure, ChatListChange>> _chatChangeSub;

  @override
  Future<void> close() async {
    try {
      await _chatChangeSub.cancel();
    } finally {
      try {
        _scrollController.dispose();
      } finally {
        await super.close();
      }
    }
  }

  // Add a listener to scrollController events
  // and fetch more chats when reaching the bottom
  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(const LoadChatListNextSlice());
      }
    });
  }

  /// Subscribes to passive chat change events from the repository.
  ///
  /// Stream emissions are converted into `ChatChangeReceived` events to
  /// ensure that all state updates go through the BLoC event pipeline
  /// (streams must never emit states directly).
  void _addListenerToSubscription() {
    _chatChangeSub = _subscribeToChatList().listen((event) {
      add(ChatChangeReceived(event));
    });
  }

  void _onChatChangeReceived(
    ChatChangeReceived event,
    Emitter<ChatListState> emit,
  ) {
    event.chatChange.fold(
      (failure) {
        emit(
          ChatListFailure(
            error: failure.message,
            chats: state.chats,
            nextCursor: state.nextCursor,
          ),
        );
      },
      (chatChange) {
        final updatedChats = switch (chatChange) {
          ChatInserted(:final chat) => _upsertChatAtTop(chat),
          ChatUpdated(:final chat) => _upsertChatAtTop(chat),
        };

        emit(
          state.copyWith(
            chats: updatedChats,
            nextCursor: state.nextCursor,
          ),
        );
      },
    );
  }

  Future<void> _onLoadChatListNextSlice(
    LoadChatListNextSlice event,
    Emitter<ChatListState> emit,
  ) async {
    if (state.chats.isNotEmpty && state.nextCursor == null) {
      return;
    }

    final previousChats = state.chats;
    final previousCursor = state.nextCursor;

    emit(
      ChatListLoading(
        chats: previousChats,
        nextCursor: previousCursor,
      ),
    );

    final result = await _getChatListSlice(
      GetChatListSliceParams(
        limit: _pageSize,
        cursor: previousCursor,
      ),
    );

    result.fold(
      (error) {
        emit(
          ChatListFailure(
            error: error.message,
            chats: previousChats,
            nextCursor: previousCursor,
          ),
        );
      },
      (chatListSlice) {
        emit(
          ChatListSuccess(
            chats: _mergeChats(
              existingChats: previousChats,
              chatListSlice: chatListSlice,
            ),
            nextCursor: chatListSlice.nextCursor,
          ),
        );
      },
    );
  }

  /// The scroll controller.
  ScrollController get scrollController => _scrollController;

  List<Chat> _mergeChats({
    required List<Chat> existingChats,
    required ChatListSlice chatListSlice,
  }) {
    return [
      ...existingChats,
      ...chatListSlice.chats.where(
        (chat) => existingChats.every(
          (existingChat) => existingChat.id != chat.id,
        ),
      ),
    ];
  }

  List<Chat> _upsertChatAtTop(Chat chat) {
    return [
      chat,
      ...state.chats.where((existingChat) => existingChat.id != chat.id),
    ];
  }
}
