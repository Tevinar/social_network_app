import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';

/// The map exception to failure.
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) {
    return NetworkFailure(debugMessage: error.message);
  }

  if (error is ServerException) {
    switch (error.code) {
      case '401':
      case '403':
      case 'PGRST301':
        return UnauthorizedFailure(debugMessage: error.message);

      case '404':
        return NotFoundFailure(debugMessage: error.message);

      case '23505':
        return ValidationFailure(
          'This value already exists.',
          debugMessage: error.message,
        );

      case '23502':
        return ValidationFailure(
          'Some required information is missing.',
          debugMessage: error.message,
        );

      default:
        return UnexpectedFailure(debugMessage: error.message);
    }
  }

  return UnexpectedFailure(debugMessage: error.toString());
}
