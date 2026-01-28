// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';

import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';

class UserSignOut implements UseCase<void, NoParams> {
  AuthRepository authRepository;
  UserSignOut({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return authRepository.signOut();
  }
}
