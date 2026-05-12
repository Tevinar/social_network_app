import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// Watches authentication state changes.
class WatchAuthStateChanges
    implements NoParamsStreamUseCase<Either<Failure, User?>> {
  /// Creates a [WatchAuthStateChanges].
  WatchAuthStateChanges({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Stream<Either<Failure, User?>> call() {
    return _authRepository.authStateChanges();
  }
}
