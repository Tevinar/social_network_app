import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Stream<Either<ServerFailure, User?>> authStateChanges();

  Future<Either<ServerFailure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<ServerFailure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<ServerFailure, void>> signOut();
}
