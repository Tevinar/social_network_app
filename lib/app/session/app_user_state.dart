part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {
  const AppUserState();
}

final class AppUserLoading extends AppUserState {}

final class AppUserSignedOut extends AppUserState {}

final class AppUserSignedIn extends AppUserState {
  const AppUserSignedIn(this.user);
  final User user;
}

final class AppUserFailure extends AppUserState {
  const AppUserFailure(this.error);
  final String error;
}
