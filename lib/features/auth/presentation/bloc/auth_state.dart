part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthSignedOut extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignedIn extends AuthState {
  final User user;

  const AuthSignedIn(this.user);
}

final class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);
}
