part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

/// User intent: sign up
final class AuthSignup extends AuthEvent {
  AuthSignup({required this.name, required this.email, required this.password});
  final String name;
  final String email;
  final String password;
}

/// User intent: sign in
final class AuthSignIn extends AuthEvent {
  AuthSignIn({required this.email, required this.password});
  final String email;
  final String password;
}

/// Internal event: auth state changed from repository stream
class _AuthStateChanged extends AuthEvent {
  _AuthStateChanged(this.authState);
  final Either<Failure, User?> authState;
}
