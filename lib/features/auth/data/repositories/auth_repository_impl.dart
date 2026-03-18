import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  const AuthRepositoryImpl({required AuthRemoteDataSource authRemoteDataSource})
    : _authRemoteDataSource = authRemoteDataSource;

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await _authRemoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await _authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<UserModel> Function() fn,
  ) async {
    try {
      final user = await fn();
      return right(user.toEntity());
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      return right(_authRemoteDataSource.signOut());
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, User?>> authStateChanges() async* {
    try {
      await for (final userModel in _authRemoteDataSource.authStateChanges()) {
        // userModel == null → signed out (valid state)
        if (userModel == null) {
          yield const Right(null);
        } else {
          yield Right(userModel.toEntity());
        }
      }
    } catch (e) {
      // Any unexpected stream error is translated into a Failure
      yield Left(mapExceptionToFailure(e));
    }
  }
}
