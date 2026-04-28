/// Represents failure.
sealed class Failure {
  // optional, internal

  const Failure(this.message, {this.debugMessage});

  /// The message.
  final String message; // user-facing (safe)
  /// The debug message.
  final String? debugMessage;
}

/// Represents network failure.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({String? debugMessage})
    : super('No internet connection.', debugMessage: debugMessage);
}

/// Represents unauthorized failure.
class UnauthorizedFailure extends Failure {
  /// Creates a [UnauthorizedFailure].
  const UnauthorizedFailure({String? debugMessage})
    : super(
        'Your session has expired. Please sign in again.',
        debugMessage: debugMessage,
      );
}

/// Represents authentication failure.
class AuthenticationFailure extends Failure {
  /// Creates an [AuthenticationFailure].
  const AuthenticationFailure(super.message, {super.debugMessage});
}

/// Represents validation failure.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure(super.message, {super.debugMessage});
}

/// Represents not found failure.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure({String? debugMessage})
    : super('Requested resource not found.', debugMessage: debugMessage);
}

/// Represents unexpected failure.
class UnexpectedFailure extends Failure {
  /// Creates a [UnexpectedFailure].
  const UnexpectedFailure({String? debugMessage})
    : super(
        'Something went wrong. Please try again.',
        debugMessage: debugMessage,
      );
}
