import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failure_messages.dart';
import 'package:social_app/core/errors/failures.dart';

/// Maps one internal exception into the app-facing [Failure] hierarchy.
///
/// This is the boundary where infrastructure and parsing exceptions are turned
/// into user-safe failures that presentation and domain layers can consume.
/// Messages produced here are intentionally broader and safer than the raw
/// exception details, while optional debug messages preserve useful context for
/// development and logging.
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) {
    return NetworkFailure(debugMessage: error.message);
  }

  if (error is UnauthorizedException) {
    return UnauthorizedFailure(debugMessage: error.message);
  }

  if (error is InvalidResponseException) {
    return UnexpectedFailure(debugMessage: error.message);
  }

  if (error is ServerException) {
    return _mapServerExceptionToFailure(error);
  }

  if (error is UnexpectedException) {
    return UnexpectedFailure(debugMessage: error.message);
  }

  return UnexpectedFailure(debugMessage: error.toString());
}

/// Maps one validated backend [ServerException] into a user-facing [Failure].
///
/// The primary dispatch key is the backend's stable error
/// [ServerException.code] because that is the most explicit contract between
/// backend and client. A status-code fallback is still used for resilience
/// when the client receives a code it does not yet understand.
Failure _mapServerExceptionToFailure(ServerException error) {
  switch (error.code) {
    case 'invalid_credentials':
      return AuthenticationFailure(
        AuthFailureMessages.invalidCredentials,
        debugMessage: error.message,
      );

    case 'email_already_in_use':
      return ValidationFailure(
        AuthFailureMessages.emailAlreadyInUse,
        debugMessage: error.message,
      );

    case 'user_already_signed_in_on_device':
      return AuthenticationFailure(
        AuthFailureMessages.alreadySignedInOnDevice,
        debugMessage: error.message,
      );

    case 'invalid_email':
      return ValidationFailure(
        AuthFailureMessages.invalidEmail,
        debugMessage: error.message,
      );

    case 'invalid_device_id':
      return ValidationFailure(
        AuthFailureMessages.invalidDeviceId,
        debugMessage: error.message,
      );

    case 'invalid_name':
      return ValidationFailure(
        AuthFailureMessages.invalidName,
        debugMessage: error.message,
      );

    case 'invalid_new_password':
      return ValidationFailure(
        AuthFailureMessages.invalidPassword,
        debugMessage: error.message,
      );

    case 'invalid_chat_member_id':
    case 'invalid_chat_members':
      return ValidationFailure(
        ChatFailureMessages.invalidMembers,
        debugMessage: error.message,
      );

    case 'invalid_chat_message_content':
      return ValidationFailure(
        ChatFailureMessages.invalidMessageContent,
        debugMessage: error.message,
      );

    case 'invalid_chat_candidate_cursor':
    case 'invalid_chat_list_cursor':
    case 'invalid_chat_message_cursor':
    case 'bad_request':
    case 'validation_error':
      return ValidationFailure(
        error.code == 'bad_request' || error.code == 'validation_error'
            ? CommonFailureMessages.invalidRequest
            : CommonFailureMessages.invalidCursor,
        debugMessage: error.message,
      );

    case 'invalid_refresh_token':
    case 'invalid_access_token':
    case 'unauthorized':
      return UnauthorizedFailure(debugMessage: error.message);

    case 'forbidden':
      return ForbiddenFailure(debugMessage: error.message);

    case 'chat_member_not_found':
    case 'chat_not_found':
    case 'not_found':
      return NotFoundFailure(debugMessage: error.message);

    case 'conflict':
      return ValidationFailure(
        CommonFailureMessages.conflict,
        debugMessage: error.message,
      );

    default:
      return _mapServerExceptionStatusToFailure(error);
  }
}

/// Provides a coarse fallback mapping when the backend code is unknown.
///
/// This keeps the client behavior reasonable for new or unhandled backend
/// error codes by falling back to the HTTP status code instead of always
/// collapsing immediately to [UnexpectedFailure].
Failure _mapServerExceptionStatusToFailure(ServerException error) {
  switch (error.statusCode) {
    case 400:
      return ValidationFailure(
        CommonFailureMessages.invalidRequest,
        debugMessage: error.message,
      );

    case 401:
      return UnauthorizedFailure(debugMessage: error.message);

    case 403:
      return ForbiddenFailure(debugMessage: error.message);

    case 404:
      return NotFoundFailure(debugMessage: error.message);

    case 409:
      return ValidationFailure(
        CommonFailureMessages.conflict,
        debugMessage: error.message,
      );

    default:
      return UnexpectedFailure(debugMessage: error.message);
  }
}
