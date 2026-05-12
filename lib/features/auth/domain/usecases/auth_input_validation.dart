import 'package:social_app/core/errors/failure_messages.dart';
import 'package:social_app/core/errors/failures.dart';

/// Minimum allowed password length for email/password authentication.
const int _minimumPasswordLength = 6;

/// Basic email pattern used for local auth input validation.
final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Validates email/password credentials before calling auth repositories.
///
/// Returns a [ValidationFailure] when the email format is invalid or the
/// password is shorter than the minimum accepted length. Returns `null` when
/// both values pass local validation.
ValidationFailure? validateAuthEmailAndPassword({
  required String email,
  required String password,
}) {
  if (!_emailRegExp.hasMatch(email)) {
    return const ValidationFailure(AuthFailureMessages.invalidEmail);
  }

  if (password.length < _minimumPasswordLength) {
    return const ValidationFailure(AuthFailureMessages.invalidPassword);
  }

  return null;
}
