import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/sources/remote/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:social_app/features/auth/data/sources/local/current_auth_user_store.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';

/// An auth repository impl.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates a [AuthRepositoryImpl].
  const AuthRepositoryImpl({
    required AuthRemoteDataSource authRemoteDataSource,
    required AuthSessionStore authSessionStore,
    required CurrentAuthUserStore currentAuthUserStore,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _authSessionStore = authSessionStore,
       _currentAuthUserStore = currentAuthUserStore;

  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthSessionStore _authSessionStore;
  final CurrentAuthUserStore _currentAuthUserStore;

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final authenticatedUser = await _authRemoteDataSource
          .signInWithEmailPassword(
            email: email,
            password: password,
          );
      await _currentAuthUserStore.saveCurrentUser(authenticatedUser.user);

      try {
        await _authSessionStore.saveSession(authenticatedUser.session);
      } on Exception {
        await _currentAuthUserStore.clearCurrentUser();
        rethrow;
      }

      return right(authenticatedUser.user.toEntity());
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
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final authenticatedUser = await _authRemoteDataSource
          .signUpWithEmailPassword(
            name: name,
            email: email,
            password: password,
          );
      await _currentAuthUserStore.saveCurrentUser(authenticatedUser.user);

      try {
        await _authSessionStore.saveSession(authenticatedUser.session);
      } on Exception {
        await _currentAuthUserStore.clearCurrentUser();
        rethrow;
      }

      return right(authenticatedUser.user.toEntity());
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
      await _authSessionStore.clearSession();
      await _currentAuthUserStore.clearCurrentUser();
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
  Stream<Either<Failure, User?>> authStateChanges() async* {
    try {
      await for (final user in _currentAuthUserStore.watchCurrentUser()) {
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
