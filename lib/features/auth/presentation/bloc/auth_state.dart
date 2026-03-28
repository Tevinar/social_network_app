part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthSignedOut extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.user);
  final User user;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
}
