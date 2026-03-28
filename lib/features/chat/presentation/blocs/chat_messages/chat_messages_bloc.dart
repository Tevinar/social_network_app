import 'dart:async';

import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:social_app/features/chat/domain/usecases/create_chat_message.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_messages_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_messages_page.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

/// BLoC responsible for displaying a paginated list of chatMessages.
///
/// This bloc combines:
/// - pagination via use cases (`GetChatMessagesPage`, `GetChatMessagesCount`)
/// - real-time chatMessages updates via a passive repository stream
/// - infinite scrolling driven by a `ScrollController`
///
/// Chat changes (insert/update/delete) are received through a stream and
/// converted into events to ensure all state mutations flow through the
/// BLoC event system.

/// Manages the chatMessages feed state, including pagination, loading states,
/// and real-time updates to already loaded chatMessages.
class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetChatMessagesPage _getChatMessagesPage;
  final GetChatMessagesCount _getChatMessagesCount;
  final ChatMessageRepository _repository;
  final CreateChatMessage _createChatMessage;

  final ScrollController _scrollController = ScrollController();

  late final StreamSubscription<Either<Failure, ChatMessageChange>> _chatMessageChangeSub;

  /// Creates the ChatMessagesBloc and immediately:
  /// - starts listening to scroll events for pagination
  /// - subscribes to real-time chatMessages changes
  /// - triggers the initial page load
  ChatMessagesBloc({
    required GetChatMessagesPage getChatMessagesPage,
    required GetChatMessagesCount getChatMessagesCount,
    required ChatMessageRepository repository,
    required CreateChatMessage createChatMessage,
  }) : _getChatMessagesPage = getChatMessagesPage,
       _getChatMessagesCount = getChatMessagesCount,
       _repository = repository,
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
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
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
    _chatMessageChangeSub = _repository.watchChatMessageChanges().listen((
      Either<Failure, ChatMessageChange> event,
    ) {
      add(ChatMessageChangeReceived(event));
    });
  }

  Future<void> _onAddChatMessage(
    AddChatMessage event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final Either<Failure, dynamic> result = await _createChatMessage(
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
        // No need to do anything, the new chatMessage will be emitted by the stream subscription
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
        chatMessages: [],
        pageNumber: 1,
      ),
    );
    add(LoadChatMessagesNextPage());
  }

  /// Applies real-time chatMessages changes (insert/update/delete) to the current state.
  ///
  /// These changes may affect chatMessages that were already loaded via pagination.
  /// This handler does not trigger refetching or pagination.
  void _onChatChangeReceived(
    ChatMessageChangeReceived event,
    Emitter<ChatMessagesState> emit,
  ) {
    event.chatMessageChange.fold(
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
      (chatMessageChange) {
        if (chatMessageChange is ChatMessageInserted) {
          emit(
            state.copyWith(
              chatMessages: [
                chatMessageChange.chatMessage,
                ...state.chatMessages,
              ],
              totalChatMessagesInDatabase: (state.totalChatMessagesInDatabase ?? 0) + 1,
            ),
          );
        }

        if (chatMessageChange is ChatMessageUpdated) {
          emit(
            state.copyWith(
              chatMessages: state.chatMessages
                  .map(
                    (chatMessage) => chatMessage.id == chatMessageChange.chatMessage.id
                        ? chatMessageChange.chatMessage
                        : chatMessage,
                  )
                  .toList(),
            ),
          );
        }

        if (chatMessageChange is ChatMessageDeleted) {
          emit(
            state.copyWith(
              chatMessages: state.chatMessages
                  .where(
                    (chatMessage) => chatMessage.id != chatMessageChange.chatMessageId,
                  )
                  .toList(),
              totalChatMessagesInDatabase: (state.totalChatMessagesInDatabase ?? 1) - 1,
            ),
          );
        }
      },
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
    final Either<Failure, List<ChatMessage>> result = await _getChatMessagesPage(
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
        final List<ChatMessage> newChatMessages = [
          ...state.chatMessages,
          ...chatsNextPage,
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

  ScrollController get scrollController => _scrollController;

  /// Lazily initializes the total number of chatMessages in the database.
  ///
  /// This value is used to determine when pagination has reached the end.
  Future<void> _initializeChatMessagesCount(
    Emitter<ChatMessagesState> emit,
  ) async {
    final Either<Failure, int> result = await _getChatMessagesCount(
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
