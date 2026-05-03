import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// An user sign up.
class UserSignUpUseCase implements UseCase<UserEntity, UserSignUpParams> {
  /// Creates a [UserSignUpUseCase].
  UserSignUpUseCase({required this.authRepository});

  /// The auth repository.
  final AuthRepository authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(UserSignUpParams params) {
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
