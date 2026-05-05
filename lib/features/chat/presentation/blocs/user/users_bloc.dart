import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_page.dart';

part 'users_event.dart';
part 'users_state.dart';

/// A users bloc.
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  /// Creates a [UsersBloc].
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
  final ScrollController _scrollController = ScrollController();
  final GetUsersPage _getUsersPage;
  final GetUsersCount _getUsersCount;

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
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
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
    if (state.users.length == state.totalUsersInDatabase &&
        state.totalUsersInDatabase != 0) {
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
    final result = await _getUsersPage(
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
        final newUsers = <User>[...state.users, ...usersNextPage];
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

  /// The scroll controller.
  ScrollController get scrollController => _scrollController;

  Future<void> _initializeUsersCount(Emitter<UsersState> emit) async {
    final result = await _getUsersCount(const NoParams());
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
