import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/usecases/get_chats_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_chats_page.dart';
import 'package:social_app/features/chat/domain/usecases/watch_chat_changes.dart';

part 'chats_event.dart';
part 'chats_state.dart';

/// BLoC responsible for displaying a paginated list of chats.
///
/// This bloc combines:
/// - pagination via use cases (`GetChatsPage`, `GetChatsCount`)
/// - real-time chat updates via a stream use case
/// - infinite scrolling driven by a `ScrollController`
///
/// Chat changes (insert/update/delete) are received through a stream and
/// converted into events to ensure all state mutations flow through the
/// BLoC event system.

/// Manages the chat feed state, including pagination, loading states,
/// and real-time updates to already loaded chats.
class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  /// Creates the ChatsBloc and immediately:
  /// - starts listening to scroll events for pagination
  /// - subscribes to real-time chat changes
  /// - triggers the initial page load
  ChatsBloc({
    required GetChatsPage getChatsPage,
    required GetChatsCount getChatsCount,
    required WatchChatChanges watchChatChanges,
  }) : _getChatsPage = getChatsPage,
       _getChatsCount = getChatsCount,
       _watchChatChanges = watchChatChanges,
       super(const ChatsLoading(chats: [], pageNumber: 1)) {
    on<LoadChatsNextPage>(_onLoadChatsNextPage);
    on<ChatChangeReceived>(_onChatChangeReceived);

    _addListenerToScrollController();
    _addListenerToSubscription();

    add(LoadChatsNextPage());
  }
  final GetChatsPage _getChatsPage;
  final GetChatsCount _getChatsCount;
  final WatchChatChanges _watchChatChanges;

  final ScrollController _scrollController = ScrollController();

  late final StreamSubscription<Either<Failure, ChatChange>> _chatChangeSub;

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
        add(LoadChatsNextPage());
      }
    });
  }

  /// Subscribes to passive chat change events from the repository.
  ///
  /// Stream emissions are converted into `ChatChangeReceived` events to
  /// ensure that all state updates go through the BLoC event pipeline
  /// (streams must never emit states directly).
  void _addListenerToSubscription() {
    _chatChangeSub = _watchChatChanges(const NoParams()).listen((
      event,
    ) {
      add(ChatChangeReceived(event));
    });
  }

  /// Applies real-time chat changes (insert/update/delete) to the current state.
  ///
  /// These changes may affect chats that were already loaded via pagination.
  /// This handler does not trigger refetching or pagination.
  void _onChatChangeReceived(
    ChatChangeReceived event,
    Emitter<ChatsState> emit,
  ) {
    event.chatChange.fold(
      (failure) {
        emit(
          ChatsFailure(
            error: failure.message,
            chats: state.chats,
            pageNumber: state.pageNumber,
            totalChatsInDatabase: state.totalChatsInDatabase,
          ),
        );
      },
      (chatChange) {
        if (chatChange is ChatInserted) {
          emit(
            state.copyWith(
              chats: [chatChange.chat, ...state.chats],
              totalChatsInDatabase: (state.totalChatsInDatabase ?? 0) + 1,
            ),
          );
        }

        if (chatChange is ChatUpdated) {
          emit(
            state.copyWith(
              chats: state.chats
                  .map(
                    (chat) =>
                        chat.id == chatChange.chat.id ? chatChange.chat : chat,
                  )
                  .toList(),
            ),
          );
        }

        if (chatChange is ChatDeleted) {
          emit(
            state.copyWith(
              chats: state.chats
                  .where((chat) => chat.id != chatChange.chatId)
                  .toList(),
              totalChatsInDatabase: (state.totalChatsInDatabase ?? 1) - 1,
            ),
          );
        }
      },
    );
  }

  /// Loads the next page of chats if available.
  ///
  /// Pagination is skipped if:
  /// - the total number of chats is already loaded
  /// - a loading operation is already in progress
  Future<void> _onLoadChatsNextPage(
    LoadChatsNextPage event,
    Emitter<ChatsState> emit,
  ) async {
    if (state.totalChatsInDatabase == null) {
      await _initializeChatsCount(emit);
    }
    // If we don't have more chats to load, do nothing
    if (state.chats.length == state.totalChatsInDatabase &&
        state.totalChatsInDatabase != 0) {
      return;
    }

    // Avoid emitting loading state if we already have chats loading
    // This is not triggered on the initial load
    if (state is ChatsLoading && state.chats.isNotEmpty) {
      return;
    }

    emit(
      ChatsLoading(
        chats: state.chats,
        pageNumber: state.pageNumber,
        totalChatsInDatabase: state.totalChatsInDatabase,
      ),
    );
    final result = await _getChatsPage(
      state.pageNumber,
    );
    result.fold(
      (error) {
        emit(
          ChatsFailure(
            error: error.message,
            chats: state.chats,
            pageNumber: state.pageNumber,
            totalChatsInDatabase: state.totalChatsInDatabase,
          ),
        );
      },
      (chatsNextPage) {
        final newChats = <Chat>[...state.chats, ...chatsNextPage];
        emit(
          ChatsSuccess(
            chats: newChats,
            pageNumber: state.pageNumber + 1,
            totalChatsInDatabase: state.totalChatsInDatabase,
          ),
        );
      },
    );
  }

  /// The scroll controller.
  ScrollController get scrollController => _scrollController;

  /// Lazily initializes the total number of chats in the database.
  ///
  /// This value is used to determine when pagination has reached the end.
  Future<void> _initializeChatsCount(Emitter<ChatsState> emit) async {
    final result = await _getChatsCount(const NoParams());
    result.fold(
      (error) {
        emit(
          ChatsFailure(
            error: error.message,
            chats: state.chats,
            pageNumber: state.pageNumber,
          ),
        );
      },
      (count) {
        emit(
          ChatsLoading(
            chats: state.chats,
            pageNumber: state.pageNumber,
            totalChatsInDatabase: count,
          ),
        );
      },
    );
  }
}
