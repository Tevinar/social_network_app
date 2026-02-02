import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/usecases/get_chats_count.dart';
import 'package:bloc_app/features/chat/domain/usecases/get_chats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ScrollController _scrollController = ScrollController();
  final GetChatsPage _getChatsPage;
  final GetChatsCount _getChatsCount;

  ChatsBloc({
    required GetChatsPage getChatsPage,
    required GetChatsCount getChatsCount,
  }) : _getChatsPage = getChatsPage,
       _getChatsCount = getChatsCount,
       super(const ChatsLoading(chats: [], pageNumber: 1)) {
    _addListenerToScrollController();
    on<LoadChatsNextPage>(_onLoadChatsNextPage);
    add(LoadChatsNextPage());
  }

  // Add a listener to scrollController events
  // and fetch more users when reaching the bottom
  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(LoadChatsNextPage());
      }
    });
  }

  Future<void> _onLoadChatsNextPage(
    LoadChatsNextPage event,
    Emitter<ChatsState> emit,
  ) async {
    if (state.totalChatsInDatabase == null) {
      await _initializeChatsCount(emit);
    }
    // If we don't have more users to load, do nothing
    if (state.chats.length == state.totalChatsInDatabase &&
        state.totalChatsInDatabase != 0) {
      return;
    }

    // Avoid emitting loading state if we already have users loading
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
    final Either<Failure, List<Chat>> result = await _getChatsPage(
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
        List<Chat> newChats = [...state.chats, ...chatsNextPage];
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

  ScrollController get scrollController => _scrollController;

  Future<void> _initializeChatsCount(Emitter<ChatsState> emit) async {
    final Either<Failure, int> result = await _getChatsCount(NoParams());
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
