import 'dart:async';

import 'package:bloc_app/core/common/entities/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final ScrollController scrollController = ScrollController();

  UserListBloc() : super(UserListState.initial()) {
    addListenerToScrollController();
    on<UserListEvent>(_getDataForPage);
  }

  // Add a listener to scrollController events
  // and fetch more users when reaching the bottom
  void addListenerToScrollController() {
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        state.fetchUsersState = RequestState.init;
        add(ByPageGetUsers(nextPage: null));
      }
      if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {}
    });
  }

  FutureOr<void> _getDataForPage(
      ByPageGetUsers event, Emitter<UserListState> emit) {
        try {
          if(event.nextPage!=null){
            emit(state.copyWith(fetchUsersState: RequestState.loading));
          }
          final result = await getUsersByPage(event.nextPage??state.pageNumber);
          result.fold((l) {
            emit(state.copyWith(fetchUsersState: RequestState.error));
          }, (result) {
            emit(state.copyWith(
              fetchUsersState: RequestState.success , 
              users: [ ...state.users , ...result ] , 
              pageNumber: state.pageNumber+1
              ));
          });
        } catch (e) {
          emit(state.copyWith(fetchUsersState: RequestState.error));
        }
      }
}
