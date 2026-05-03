part of 'app_user_cubit.dart';

@immutable
/// Represents app user state.
sealed class AppUserState {
  const AppUserState();
}

/// An app user loading.
final class AppUserLoading extends AppUserState {}

/// An app user signed out.
final class AppUserSignedOut extends AppUserState {}

/// An app user signed in.
final class AppUserSignedIn extends AppUserState {
  /// Creates a [AppUserSignedIn].
  const AppUserSignedIn(this.user);

  /// The user.
  final UserEntity user;
}

/// Represents app user failure.
final class AppUserFailure extends AppUserState {
  /// Creates a [AppUserFailure].
  const AppUserFailure(this.error);

  /// The error.
  final String error;
}
