import 'package:bloc_app/core/errors/exceptions.dart';
import 'package:bloc_app/core/errors/failures.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) {
    return const NetworkFailure();
  }

  if (error is ServerException) {
    print('Error Code: ${error.code}, Message: ${error.message}');
    switch (error.code) {
      case '401':
      case '403':
      case 'PGRST301':
        return const UnauthorizedFailure();

      case '404':
        return const NotFoundFailure();

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
