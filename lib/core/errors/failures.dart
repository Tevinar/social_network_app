sealed class Failure {
  final String message; // user-facing (safe)
  final String? debugMessage; // optional, internal

  const Failure(this.message, {this.debugMessage});
}

class NetworkFailure extends Failure {
  const NetworkFailure({String? debugMessage})
    : super('No internet connection.', debugMessage: debugMessage);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String? debugMessage, String? code})
    : super(
        'Your session has expired. Please sign in again.',
        debugMessage: debugMessage,
      );
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.debugMessage});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String? debugMessage})
    : super('Requested resource not found.', debugMessage: debugMessage);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String? debugMessage})
    : super(
        'Something went wrong. Please try again.',
        debugMessage: debugMessage,
      );
}
