import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Watches authentication state changes.
class WatchAuthStateChanges
    implements StreamUseCase<Either<Failure, User?>, NoParams> {
  /// Creates a [WatchAuthStateChanges].
  WatchAuthStateChanges({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Stream<Either<Failure, User?>> call(NoParams params) {
    return _authRepository.authStateChanges();
  }
}
