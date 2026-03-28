import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// An user sign up.
class UserSignUp implements UseCase<User, UserSignUpParams> {
  /// Creates a [UserSignUp].
  UserSignUp({required this.authRepository});

  /// The auth repository.
  final AuthRepository authRepository;

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) {
    return authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

/// An user sign up params.
class UserSignUpParams {
  /// Creates a [UserSignUpParams].
  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });

  /// The name.
  final String name;

  /// The email.
  final String email;

  /// The password.
  final String password;
}
