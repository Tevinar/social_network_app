import 'dart:async';

import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/features/chat/domain/usecases/get_users_by_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final ScrollController _scrollController = ScrollController();
  final GetUsersByPage _getUsersByPage;

  UserListBloc({required GetUsersByPage getUsersByPage})
    : _getUsersByPage = getUsersByPage,
      super(UserListState.initial()) {
    addListenerToScrollController();
    on<ByPageGetUsers>(_onByPageGetUsers);
  }

  // Add a listener to scrollController events
  // and fetch more users when reaching the bottom
  void addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        state.fetchUsersState = RequestState.init;
        add(ByPageGetUsers(nextPage: null));
      }
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });
  }

  Future<void> _onByPageGetUsers(
    ByPageGetUsers event,
    Emitter<UserListState> emit,
  ) async {
    try {
      if (event.nextPage != null) {
        emit(state.copyWith(fetchUsersState: RequestState.loading));
      }
      final result = await _getUsersByPage(event.nextPage ?? state.pageNumber);
      result.fold(
        (l) {
          emit(state.copyWith(fetchUsersState: RequestState.error));
        },
        (result) {
          emit(
            state.copyWith(
              fetchUsersState: RequestState.success,
              users: [...state.users, ...result],
              pageNumber: state.pageNumber + 1,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(fetchUsersState: RequestState.error));
    }
  }
}
