import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';

/// The map exception to failure.
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) {
    return NetworkFailure(debugMessage: error.message);
  }

  if (error is ServerException) {
    return _mapServerExceptionToFailure(error);
  }

  return UnexpectedFailure(debugMessage: error.toString());
}

Failure _mapServerExceptionToFailure(ServerException error) {
  switch (error.code) {
    case 'invalid_credentials':
      return AuthenticationFailure(
        'Invalid email or password.',
        debugMessage: error.message,
      );

    case 'email_already_in_use':
      return ValidationFailure(
        'Email already in use.',
        debugMessage: error.message,
      );

    case 'user_already_signed_in_on_device':
      return AuthenticationFailure(
        'This account is already signed in on this device.',
        debugMessage: error.message,
      );

    case 'invalid_email':
    case 'invalid_device_id':
    case 'invalid_name':
    case 'invalid_new_password':
      return ValidationFailure(error.message, debugMessage: error.message);

    case 'invalid_refresh_token':
    case 'invalid_access_token':
    case '401':
    case '403':
      return UnauthorizedFailure(debugMessage: error.message);

    case '404':
      return NotFoundFailure(debugMessage: error.message);

    default:
      return UnexpectedFailure(debugMessage: error.message);
  }
}
