import 'package:bloc_app/core/constants/error_messages.dart';
import 'package:bloc_app/core/errors/exceptions.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';

import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/core/network/connection_checker.dart';
import 'package:bloc_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final ConnectionChecker _connectionChecker;
  const AuthRepositoryImpl({
    required AuthRemoteDataSource authRemoteDataSource,
    required ConnectionChecker connectionChecker,
  }) : _connectionChecker = connectionChecker,
       _authRemoteDataSource = authRemoteDataSource;

  @override
  Future<Either<ServerFailure, User>> signInWithEmailPassword({
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
  Future<Either<ServerFailure, User>> signUpWithEmailPassword({
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

  Future<Either<ServerFailure, User>> _getUser(
    Future<UserModel> Function() fn,
  ) async {
    try {
      if (!await _connectionChecker.isConnected) {
        return left(ServerFailure(ErrorMessages.noConnection));
      }

      final user = await fn();
      return right(user.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<ServerFailure, void>> signOut() async {
    try {
      if (!await _connectionChecker.isConnected) {
        return left(ServerFailure(ErrorMessages.noConnection));
      }
      return right(_authRemoteDataSource.signOut());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<ServerFailure, User?>> authStateChanges() async* {
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
      yield Left(ServerFailure(e.toString()));
    }
  }
}
