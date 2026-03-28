import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

class UserSignIn implements UseCase<User, UserSignInParams> {
  UserSignIn({required this.authRepositoy});
  final AuthRepository authRepositoy;

  @override
  Future<Either<Failure, User>> call(UserSignInParams params) {
    return authRepositoy.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignInParams {
  UserSignInParams({required this.email, required this.password});
  final String email;
  final String password;
}
