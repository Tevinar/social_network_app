import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/data_sources/auth_session_store.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// An auth repository impl.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates a [AuthRepositoryImpl].
  const AuthRepositoryImpl({
    required AuthRemoteDataSource authRemoteDataSource,
    required AuthSessionStore authSessionStore,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _authSessionStore = authSessionStore;

  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthSessionStore _authSessionStore;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authRemoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );
      return right(user.toEntity());
    } on Exception catch (error, stackTrace) {
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
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({
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
    } on Exception catch (error, stackTrace) {
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
    } on Exception catch (error, stackTrace) {
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
  Stream<Either<Failure, UserEntity?>> authStateChanges() async* {
    try {
      await for (final session in _authSessionStore.watchSession()) {
        final user = session?.user;

        if (user == null) {
          yield right(null);
        } else {
          yield right(user.toEntity());
        }
      }
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in AuthRepositoryImpl.authStateChanges',
          error: error,
          stackTrace: stackTrace,
        );
      }

      yield left(failure);
    }
  }
}
