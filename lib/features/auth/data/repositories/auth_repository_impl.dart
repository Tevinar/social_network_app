import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource authRemoteDataSource})
    : _authRemoteDataSource = authRemoteDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authRemoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );
      return right(user.toEntity());
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in AuthRepositoryImpl.signInWithEmailPassword',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      return right(user.toEntity());
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in AuthRepositoryImpl.signUpWithEmailPassword',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authRemoteDataSource.signOut();
      return right(null);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in AuthRepositoryImpl.signOut',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, User?>> authStateChanges() async* {
    try {
      await for (final UserModel? userModel
          in _authRemoteDataSource.authStateChanges()) {
        // userModel == null → signed out (valid state)
        if (userModel == null) {
          yield right(null);
        } else {
          yield right(userModel.toEntity());
        }
      }
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in AuthRepositoryImpl.authStateChanges',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Any unexpected stream error is translated into a Failure
      yield left(failure);
    }
  }
}
