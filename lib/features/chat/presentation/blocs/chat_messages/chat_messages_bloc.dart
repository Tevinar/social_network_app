import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/'
    'chat_message_change.dart';
import 'package:social_app/features/chat/domain/usecases/'
    'create_chat_message.dart';
import 'package:social_app/features/chat/domain/usecases/'
    'get_chat_messages_count.dart';
import 'package:social_app/features/chat/domain/usecases/'
    'get_chat_messages_page.dart';
import 'package:social_app/features/chat/domain/usecases/'
    'watch_chat_message_changes.dart';

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

/// BLoC responsible for displaying a paginated list of chatMessages.
///
/// This bloc combines:
/// - pagination via use cases (`GetChatMessagesPage`, `GetChatMessagesCount`)
/// - real-time chatMessages updates via a stream use case
/// - infinite scrolling driven by a `ScrollController`
///
/// Chat changes (insert/update/delete) are received through a stream and
/// converted into events to ensure all state mutations flow through the
/// BLoC event system.

/// Manages the chatMessages feed state, including pagination, loading states,
/// and real-time updates to already loaded chatMessages.
class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  /// Creates the ChatMessagesBloc and immediately:
  /// - starts listening to scroll events for pagination
  /// - subscribes to real-time chatMessages changes
  /// - triggers the initial page load
  ChatMessagesBloc({
    required GetChatMessagesPage getChatMessagesPage,
    required GetChatMessagesCount getChatMessagesCount,
    required WatchChatMessageChanges watchChatMessageChanges,
    required CreateChatMessage createChatMessage,
  }) : _getChatMessagesPage = getChatMessagesPage,
       _getChatMessagesCount = getChatMessagesCount,
       _watchChatMessageChanges = watchChatMessageChanges,
       _createChatMessage = createChatMessage,
       super(
         const ChatMessagesLoading(chatId: '', chatMessages: [], pageNumber: 1),
       ) {
    on<LoadChatMessagesNextPage>(_onLoadChatMessagesNextPage);
    on<ChatMessageChangeReceived>(_onChatChangeReceived);
    on<LoadInitialChatMessagesPage>(_onLoadInitialChatMessagesPage);
    on<AddChatMessage>(_onAddChatMessage);

    _addListenerToScrollController();
    _addListenerToSubscription();
  }
  final GetChatMessagesPage _getChatMessagesPage;
  final GetChatMessagesCount _getChatMessagesCount;
  final WatchChatMessageChanges _watchChatMessageChanges;
  final CreateChatMessage _createChatMessage;

  final ScrollController _scrollController = ScrollController();

  late final StreamSubscription<Either<Failure, ChatMessageChange>>
  _chatMessageChangeSub;

  @override
  Future<void> close() async {
    try {
      await _chatMessageChangeSub.cancel();
    } finally {
      try {
        _scrollController.dispose();
      } finally {
        await super.close();
      }
    }
  }

  // Add a listener to scrollController events
  // and fetch more chatMessages when reaching the bottom
  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(LoadChatMessagesNextPage());
      }
    });
  }

  /// Subscribes to passive chatMessages change events from the repository.
  ///
  /// Stream emissions are converted into `ChatChangeReceived` events to
  /// ensure that all state updates go through the BLoC event pipeline
  /// (streams must never emit states directly).
  void _addListenerToSubscription() {
    _chatMessageChangeSub = _watchChatMessageChanges(const NoParams()).listen((
      event,
    ) {
      add(ChatMessageChangeReceived(event));
    });
  }

  Future<void> _onAddChatMessage(
    AddChatMessage event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final result = await _createChatMessage(
      CreateChatMessageParams(chatId: event.chatId, content: event.content),
    );

    result.fold(
      (failure) {
        emit(
          ChatMessagesFailure(
            chatId: state.chatId,
            error: failure.message,
            chatMessages: state.chatMessages,
            pageNumber: state.pageNumber,
            totalChatMessagesInDatabase: state.totalChatMessagesInDatabase,
          ),
        );
      },
      (success) {
        // The realtime stream will emit the inserted chat message.
      },
    );
  }

  void _onLoadInitialChatMessagesPage(
    LoadInitialChatMessagesPage event,
    Emitter<ChatMessagesState> emit,
  ) {
    emit(
      ChatMessagesLoading(
        chatId: event.chatId,
        chatMessages: const [],
        pageNumber: 1,
      ),
    );
    add(LoadChatMessagesNextPage());
  }

  /// Applies realtime insert, update, and delete changes to the current state.
  ///
  /// These changes may affect chat messages already loaded via pagination.
  /// This handler does not trigger refetching or pagination.
  void _onChatChangeReceived(
    ChatMessageChangeReceived event,
    Emitter<ChatMessagesState> emit,
  ) {
    event.chatMessageChange.fold(
      (failure) => _emitChatChangeFailure(failure, emit),
      (chatMessageChange) => _applyChatMessageChange(chatMessageChange, emit),
    );
  }

  void _emitChatChangeFailure(
    Failure failure,
    Emitter<ChatMessagesState> emit,
  ) {
    emit(
      ChatMessagesFailure(
        chatId: state.chatId,
        error: failure.message,
        chatMessages: state.chatMessages,
        pageNumber: state.pageNumber,
        totalChatMessagesInDatabase: state.totalChatMessagesInDatabase,
      ),
    );
  }

  void _applyChatMessageChange(
    ChatMessageChange chatMessageChange,
    Emitter<ChatMessagesState> emit,
  ) {
    // Ignore changes for other chats - they will be handled
    // by their respective BLoCs
    if (_chatIdOfChange(chatMessageChange) != state.chatId) {
      return;
    }

    switch (chatMessageChange) {
      case ChatMessageInserted():
        _handleInsertedChatMessage(chatMessageChange, emit);

      case ChatMessageUpdated():
        _handleUpdatedChatMessage(chatMessageChange, emit);

      case ChatMessageDeleted():
        _handleDeletedChatMessage(chatMessageChange, emit);
    }
  }

  String _chatIdOfChange(ChatMessageChange chatMessageChange) {
    return switch (chatMessageChange) {
      ChatMessageInserted(:final chatId) => chatId,
      ChatMessageUpdated(:final chatId) => chatId,
      ChatMessageDeleted(:final chatId) => chatId,
    };
  }

  void _handleInsertedChatMessage(
    ChatMessageInserted chatMessageChange,
    Emitter<ChatMessagesState> emit,
  ) {
    final messageAlreadyExists = state.chatMessages.any(
      (chatMessage) => chatMessage.id == chatMessageChange.chatMessage.id,
    );

    emit(
      state.copyWith(
        chatMessages: messageAlreadyExists
            ? state.chatMessages
            : [
                chatMessageChange.chatMessage,
                ...state.chatMessages,
              ],
        totalChatMessagesInDatabase: messageAlreadyExists
            ? state.totalChatMessagesInDatabase
            : (state.totalChatMessagesInDatabase ?? 0) + 1,
      ),
    );
  }

  void _handleUpdatedChatMessage(
    ChatMessageUpdated chatMessageChange,
    Emitter<ChatMessagesState> emit,
  ) {
    emit(
      state.copyWith(
        chatMessages: state.chatMessages
            .map(
              (chatMessage) =>
                  chatMessage.id == chatMessageChange.chatMessage.id
                  ? chatMessageChange.chatMessage
                  : chatMessage,
            )
            .toList(),
      ),
    );
  }

  void _handleDeletedChatMessage(
    ChatMessageDeleted chatMessageChange,
    Emitter<ChatMessagesState> emit,
  ) {
    emit(
      state.copyWith(
        chatMessages: state.chatMessages
            .where(
              (chatMessage) =>
                  chatMessage.id != chatMessageChange.chatMessageId,
            )
            .toList(),
        totalChatMessagesInDatabase:
            (state.totalChatMessagesInDatabase ?? 1) - 1,
      ),
    );
  }

  /// Loads the next page of chatMessages if available.
  ///
  /// Pagination is skipped if:
  /// - the total number of chatMessages is already loaded
  /// - a loading operation is already in progress
  Future<void> _onLoadChatMessagesNextPage(
    LoadChatMessagesNextPage event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state.totalChatMessagesInDatabase == null) {
      await _initializeChatMessagesCount(emit);
    }
    // If we don't have more chatMessages to load, do nothing
    if (state.chatMessages.length == state.totalChatMessagesInDatabase &&
        state.totalChatMessagesInDatabase != 0) {
      return;
    }

    // Avoid emitting loading state if we already have chatMessages loading
    // This is not triggered on the initial load
    if (state is ChatMessagesLoading && state.chatMessages.isNotEmpty) {
      return;
    }

    emit(
      ChatMessagesLoading(
        chatId: state.chatId,
        chatMessages: state.chatMessages,
        pageNumber: state.pageNumber,
        totalChatMessagesInDatabase: state.totalChatMessagesInDatabase,
      ),
    );
    final result = await _getChatMessagesPage(
      GetChatMessagesPageParams(
        pageNumber: state.pageNumber,
        chatId: state.chatId,
      ),
    );
    result.fold(
      (error) {
        emit(
          ChatMessagesFailure(
            chatId: state.chatId,
            error: error.message,
            chatMessages: state.chatMessages,
            pageNumber: state.pageNumber,
            totalChatMessagesInDatabase: state.totalChatMessagesInDatabase,
          ),
        );
      },
      (chatsNextPage) {
        final newChatMessages = [
          ...state.chatMessages,
          ...chatsNextPage.where(
            (nextMessage) => state.chatMessages.every(
              (existingMessage) => existingMessage.id != nextMessage.id,
            ),
          ),
        ];
        emit(
          ChatMessagesSuccess(
            chatId: state.chatId,
            chatMessages: newChatMessages,
            pageNumber: state.pageNumber + 1,
            totalChatMessagesInDatabase: state.totalChatMessagesInDatabase,
          ),
        );
      },
    );
  }

  /// The scroll controller.
  ScrollController get scrollController => _scrollController;

  /// Lazily initializes the total number of chatMessages in the database.
  ///
  /// This value is used to determine when pagination has reached the end.
  Future<void> _initializeChatMessagesCount(
    Emitter<ChatMessagesState> emit,
  ) async {
    final result = await _getChatMessagesCount(
      state.chatId,
    );
    result.fold(
      (error) {
        emit(
          ChatMessagesFailure(
            chatId: state.chatId,
            error: error.message,
            chatMessages: state.chatMessages,
            pageNumber: state.pageNumber,
          ),
        );
      },
      (count) {
        emit(
          ChatMessagesLoading(
            chatId: state.chatId,
            chatMessages: state.chatMessages,
            pageNumber: state.pageNumber,
            totalChatMessagesInDatabase: count,
          ),
        );
      },
    );
  }
}
