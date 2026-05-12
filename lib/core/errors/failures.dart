/// Base type for recoverable application failures exposed beyond the data
/// layer.
///
/// A [Failure] is the user-safe representation of an error condition after low-
/// level exceptions have been mapped into something the rest of the app can
/// reason about. Use [message] for UI copy that can be shown directly to the
/// user. Use [debugMessage] for optional diagnostic context that may help with
/// logging, development, or troubleshooting, but should not be treated as
/// polished user-facing copy.
sealed class Failure {
  /// Creates a [Failure] with a safe display [message] and optional
  /// [debugMessage].
  const Failure(this.message, {this.debugMessage});

  /// Safe, user-facing copy that may be rendered directly in the UI.
  final String message;

  /// Optional developer-oriented context preserved for diagnostics.
  final String? debugMessage;
}

/// Failure raised when the app cannot complete a request because the backend
/// could not be reached reliably.
///
/// This covers transport-level problems such as timeouts, offline states, DNS
/// failures, and connection errors. It should not be used for valid HTTP
/// responses that contain an application error payload.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({String? debugMessage})
    : super(
        'Unable to reach the server. Check your connection and try again.',
        debugMessage: debugMessage,
      );
}

/// Failure raised when the current authentication state is missing, expired, or
/// otherwise no longer accepted by the backend.
///
/// This typically means the user must authenticate again before retrying the
/// action.
class UnauthorizedFailure extends Failure {
  /// Creates a [UnauthorizedFailure].
  const UnauthorizedFailure({String? debugMessage})
    : super(
        'Your session has expired. Please sign in again.',
        debugMessage: debugMessage,
      );
}

/// Failure raised when the user is authenticated but does not have permission
/// to perform the requested action.
class ForbiddenFailure extends Failure {
  /// Creates a [ForbiddenFailure].
  const ForbiddenFailure({String? debugMessage})
    : super(
        'You do not have permission to perform this action.',
        debugMessage: debugMessage,
      );
}

/// Failure raised for authentication-specific business rules that should be
/// shown directly to the user.
///
/// Examples include invalid credentials or account/session constraints that are
/// not generic authorization failures.
class AuthenticationFailure extends Failure {
  /// Creates an [AuthenticationFailure].
  const AuthenticationFailure(super.message, {super.debugMessage});
}

/// Failure raised when user input or request parameters do not satisfy business
/// or transport validation rules.
///
/// The [message] is expected to be specific enough to help the user correct the
/// invalid input.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure(super.message, {super.debugMessage});
}

/// Failure raised when the requested resource does not exist or is no longer
/// accessible by identifier.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure({String? debugMessage})
    : super('Requested resource not found.', debugMessage: debugMessage);
}

/// Failure raised when an operation fails in a way the app does not classify
/// more specifically.
///
/// This is the broad fallback for unrecognized backend responses, unexpected
/// local exceptions, or any condition that should not leak internal details to
/// the user.
class UnexpectedFailure extends Failure {
  /// Creates a [UnexpectedFailure].
  const UnexpectedFailure({String? debugMessage})
    : super(
        'Something went wrong. Please try again.',
        debugMessage: debugMessage,
      );
}
