part of 'users_bloc.dart';

@immutable
sealed class UsersState {
  final List<User> users;
  final int pageNumber;
  final int? totalUsersInDatabase;

  const UsersState({
    required this.users,
    required this.pageNumber,
    this.totalUsersInDatabase,
  });
}

final class UsersLoading extends UsersState {
  const UsersLoading({
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}

final class UsersSuccess extends UsersState {
  const UsersSuccess({
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}

final class UsersFailure extends UsersState {
  final String error;

  const UsersFailure({
    required this.error,
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}
