part of 'users_bloc.dart';

@immutable
/// Represents users state.
sealed class UsersState {
  const UsersState({
    required this.users,
    required this.pageNumber,
    this.totalUsersInDatabase,
  });

  /// The users.
  final List<UserEntity> users;

  /// The int.
  final int pageNumber;

  /// The int.
  final int? totalUsersInDatabase;
}

/// An users loading.
final class UsersLoading extends UsersState {
  /// Creates a [UsersLoading].
  const UsersLoading({
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}

/// An users success.
final class UsersSuccess extends UsersState {
  /// Creates a [UsersSuccess].
  const UsersSuccess({
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}

/// Represents users failure.
final class UsersFailure extends UsersState {
  /// Creates a [UsersFailure].
  const UsersFailure({
    required this.error,
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });

  /// The error.
  final String error;
}
