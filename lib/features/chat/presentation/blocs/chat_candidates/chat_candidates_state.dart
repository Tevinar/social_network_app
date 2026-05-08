part of 'chat_candidates_bloc.dart';

@immutable
/// Represents users state.
sealed class ChatCandidatesState {
  const ChatCandidatesState({
    required this.users,
    required this.pageNumber,
    this.totalUsersInDatabase,
  });

  /// The users.
  final List<User> users;

  /// The int.
  final int pageNumber;

  /// The int.
  final int? totalUsersInDatabase;
}

/// An users loading.
final class UsersLoading extends ChatCandidatesState {
  /// Creates a [UsersLoading].
  const UsersLoading({
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}

/// An users success.
final class UsersSuccess extends ChatCandidatesState {
  /// Creates a [UsersSuccess].
  const UsersSuccess({
    required super.users,
    required super.pageNumber,
    super.totalUsersInDatabase,
  });
}

/// Represents users failure.
final class UsersFailure extends ChatCandidatesState {
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
