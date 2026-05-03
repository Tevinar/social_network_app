import 'package:fpdart/fpdart.dart';

import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Signs out the current authenticated user.
class UserSignOutUseCase implements NoParamsUseCase<void> {
  /// Creates a [UserSignOutUseCase].
  UserSignOutUseCase({required this.authRepository});

  /// Auth repository used to perform the sign-out.
  final AuthRepository authRepository;

  @override
  /// Executes the sign-out request.
  Future<Either<Failure, void>> call() {
    return authRepository.signOut();
  }
}
