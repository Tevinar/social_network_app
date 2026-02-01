part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignup extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignup({required this.name, required this.email, required this.password});
}

final class AuthSignIn extends AuthEvent {
  final String email;
  final String password;

  AuthSignIn({required this.email, required this.password});
}

class AuthStateChanged extends AuthEvent {
  final Either<ServerFailure, User?> authState;
  AuthStateChanged(this.authState);
}
