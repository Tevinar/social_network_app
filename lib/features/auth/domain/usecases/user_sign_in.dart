import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignIn implements UseCase<User, UserSignInParams> {
  final AuthRepository authRepositoy;

  UserSignIn({required this.authRepositoy});

  @override
  Future<Either<Failure, User>> call(UserSignInParams params) {
    return authRepositoy.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignInParams {
  final String email;
  final String password;

  UserSignInParams({required this.email, required this.password});
}
