part of 'auth_bloc.dart';

@immutable
/// Represents auth event.
abstract class AuthEvent {}

/// User intent: sign up
final class AuthSignup extends AuthEvent {
  /// Creates a [AuthSignup].
  AuthSignup({required this.name, required this.email, required this.password});

  /// The name.
  final String name;

  /// The email.
  final String email;

  /// The password.
  final String password;
}

/// User intent: sign in
final class AuthSignIn extends AuthEvent {
  /// Creates a [AuthSignIn].
  AuthSignIn({required this.email, required this.password});

  /// The email.
  final String email;

  /// The password.
  final String password;
}

/// Internal event: auth state changed from repository stream
class _AuthStateChanged extends AuthEvent {
  _AuthStateChanged(this.authState);

  /// The auth state.
  final Either<Failure, User?> authState;
}
