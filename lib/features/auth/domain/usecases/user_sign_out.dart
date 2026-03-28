import 'package:fpdart/fpdart.dart';

import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Signs out the current authenticated user.
class UserSignOut implements UseCase<void, NoParams> {
  /// Creates a [UserSignOut].
  UserSignOut({required this.authRepository});

  /// Auth repository used to perform the sign-out.
  final AuthRepository authRepository;

  @override
  /// Executes the sign-out request.
  Future<Either<Failure, void>> call(NoParams params) {
    return authRepository.signOut();
  }
}
