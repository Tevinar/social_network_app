import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/auth_input_validation.dart';

/// An user sign in.
class UserSignInUseCase implements UseCase<User, UserSignInParams> {
  /// Creates a [UserSignInUseCase].
  UserSignInUseCase({required this.authRepositoy});

  /// The auth repositoy.
  final AuthRepository authRepositoy;

  @override
  Future<Either<Failure, User>> call(UserSignInParams params) {
    final email = params.email.trim();
    final validationFailure = validateAuthEmailAndPassword(
      email: email,
      password: params.password,
    );
    if (validationFailure != null) {
      return Future.value(left(validationFailure));
    }

    return authRepositoy.signInWithEmailPassword(
      email: email,
      password: params.password,
    );
  }
}

/// An user sign in params.
class UserSignInParams {
  /// Creates a [UserSignInParams].
  UserSignInParams({required this.email, required this.password});

  /// The email.
  final String email;

  /// The password.
  final String password;
}
