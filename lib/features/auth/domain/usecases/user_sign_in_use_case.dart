import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// An user sign in.
class UserSignInUseCase implements UseCase<User, UserSignInParams> {
  /// Creates a [UserSignInUseCase].
  UserSignInUseCase({required this.authRepositoy});

  /// The auth repositoy.
  final AuthRepository authRepositoy;

  @override
  Future<Either<Failure, User>> call(UserSignInParams params) {
    return authRepositoy.signInWithEmailPassword(
      email: params.email,
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
