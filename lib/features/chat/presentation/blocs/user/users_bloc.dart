import 'dart:async';

import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final ScrollController _scrollController = ScrollController();
  final GetUsersPage _getUsersPage;
  final GetUsersCount _getUsersCount;

  UsersBloc({
    required GetUsersPage getUsersPage,
    required GetUsersCount getUsersCount,
  }) : _getUsersPage = getUsersPage,
       _getUsersCount = getUsersCount,
       super(const UsersLoading(users: [], pageNumber: 1)) {
    _addListenerToScrollController();
    on<LoadUsersNextPage>(_onLoadUsersNextPage);
    add(LoadUsersNextPage());
  }

  @override
  Future<void> close() async {
    try {
      _scrollController.dispose();
    } finally {
      await super.close();
    }
  }

  // Add a listener to scrollController events
  // and fetch more users when reaching the bottom
  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(LoadUsersNextPage());
      }
    });
  }

  Future<void> _onLoadUsersNextPage(
    LoadUsersNextPage event,
    Emitter<UsersState> emit,
  ) async {
    if (state.totalUsersInDatabase == null) {
      await _initializeUsersCount(emit);
    }

    // If we don't have more users to load, do nothing
    if (state.users.length == state.totalUsersInDatabase && state.totalUsersInDatabase != 0) {
      return;
    }
    // Avoid emitting loading state if we already have users loading
    // This is not triggered on the initial load
    if (state is UsersLoading && state.users.isNotEmpty) {
      return;
    }

    emit(
      UsersLoading(
        users: state.users,
        pageNumber: state.pageNumber,
        totalUsersInDatabase: state.totalUsersInDatabase,
      ),
    );
    final Either<Failure, List<User>> result = await _getUsersPage(
      state.pageNumber,
    );
    result.fold(
      (error) {
        emit(
          UsersFailure(
            error: error.message,
            users: state.users,
            pageNumber: state.pageNumber,
            totalUsersInDatabase: state.totalUsersInDatabase,
          ),
        );
      },
      (usersNextPage) {
        final List<User> newUsers = [...state.users, ...usersNextPage];
        emit(
          UsersSuccess(
            users: newUsers,
            pageNumber: state.pageNumber + 1,
            totalUsersInDatabase: state.totalUsersInDatabase,
          ),
        );
      },
    );
  }

  ScrollController get scrollController => _scrollController;

  Future<void> _initializeUsersCount(Emitter<UsersState> emit) async {
    final Either<Failure, int> result = await _getUsersCount(NoParams());
    result.fold(
      (error) {
        emit(
          UsersFailure(
            error: error.message,
            users: state.users,
            pageNumber: state.pageNumber,
          ),
        );
      },
      (count) {
        emit(
          UsersLoading(
            users: state.users,
            pageNumber: state.pageNumber,
            totalUsersInDatabase: count,
          ),
        );
      },
    );
  }
}
