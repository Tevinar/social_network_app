part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

/// User intent: sign up
final class AuthSignup extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignup({required this.name, required this.email, required this.password});
}

/// User intent: sign in
final class AuthSignIn extends AuthEvent {
  final String email;
  final String password;

  AuthSignIn({required this.email, required this.password});
}

/// Internal event: auth state changed from repository stream
class _AuthStateChanged extends AuthEvent {
  final Either<ServerFailure, User?> authState;
  _AuthStateChanged(this.authState);
}
