part of 'user_list_bloc.dart';

class UserListState extends Equatable {
  List<User> users;
  int pageNumber;
  RequestState fetchUsersState; // request status for fetching users
  UserListState({
    required this.users,
    required this.pageNumber,
    required this.fetchUsersState,
  });
  factory UserListState.initial() {
    return UserListState(
      fetchUsersState: RequestState.init,
      users: [],
      pageNumber: 1,
    );
  }

  UserListState copyWith({
    List<User>? users,
    int? pageNumber,
    RequestState? fetchUsersState,
  }) {
    return UserListState(
      users: users ?? this.users,
      pageNumber: pageNumber ?? this.pageNumber,
      fetchUsersState: fetchUsersState ?? this.fetchUsersState,
    );
  }

  @override
  List<Object> get props => [users, pageNumber, fetchUsersState];
}

enum RequestState { init, loading, success, error }
