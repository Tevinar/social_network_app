import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Stream<Either<Failure, User?>> authStateChanges();

  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();
}
