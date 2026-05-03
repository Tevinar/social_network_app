import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Watches authentication state changes.
class WatchAuthStateChanges
    implements NoParamsStreamUseCase<Either<Failure, UserEntity?>> {
  /// Creates a [WatchAuthStateChanges].
  WatchAuthStateChanges({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Stream<Either<Failure, UserEntity?>> call() {
    return _authRepository.authStateChanges();
  }
}
