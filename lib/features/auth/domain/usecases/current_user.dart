import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/core/common/domain/entities/user.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  CurrentUser({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return authRepository.currentUser();
  }
}
