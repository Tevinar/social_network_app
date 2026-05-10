import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/auth_input_validation.dart';

/// An user sign up.
class UserSignUpUseCase implements UseCase<User, UserSignUpParams> {
  /// Creates a [UserSignUpUseCase].
  UserSignUpUseCase({required this.authRepository});

  /// The auth repository.
  final AuthRepository authRepository;

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) {
    final email = params.email.trim();
    final validationFailure = validateAuthEmailAndPassword(
      email: email,
      password: params.password,
    );
    if (validationFailure != null) {
      return Future.value(left(validationFailure));
    }

    return authRepository.signUpWithEmailPassword(
      name: params.name,
      email: email,
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
