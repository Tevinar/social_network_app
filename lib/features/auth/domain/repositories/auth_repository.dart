import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';

/// An auth repository.
abstract interface class AuthRepository {
  /// Returns the auth state changes stream.
  Stream<Either<Failure, UserEntity?>> authStateChanges();

  /// Sign up with email password.
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  /// Sign in with email password.
  Future<Either<Failure, UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign out.
  Future<Either<Failure, void>> signOut();
}
