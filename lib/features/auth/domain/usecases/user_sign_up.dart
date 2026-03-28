import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  UserSignUp({required this.authRepository});
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

class UserSignUpParams {
  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}
