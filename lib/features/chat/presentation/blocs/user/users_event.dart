part of 'users_bloc.dart';

@immutable
/// Represents users event.
sealed class UsersEvent {}

/// A load users next page widget.
class LoadUsersNextPage extends UsersEvent {}
