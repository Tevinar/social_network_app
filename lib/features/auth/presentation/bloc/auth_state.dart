part of 'auth_bloc.dart';

@immutable
/// Represents auth state.
abstract class AuthState extends Equatable {
  /// Creates a [AuthState].
  const AuthState();

  @override
  /// The props.
  List<Object?> get props => [];
}

/// An auth signed out.
final class AuthSignedOut extends AuthState {}

/// An auth loading.
final class AuthLoading extends AuthState {}

/// An auth signed in.
final class AuthSignedIn extends AuthState {
  /// Creates a [AuthSignedIn].
  const AuthSignedIn(this.user);

  /// The user.
  final UserEntity user;
}

/// Represents auth failure.
final class AuthFailure extends AuthState {
  /// Creates a [AuthFailure].
  const AuthFailure(this.message);

  /// The message.
  final String message;
}
