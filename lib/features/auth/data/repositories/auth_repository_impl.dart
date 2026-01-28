import 'package:bloc_app/core/constants/error_messages.dart';
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:bloc_app/core/common/entities/user.dart';

import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/network/connection_checker.dart';
import 'package:bloc_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await authRemoteDataSource.signInWithEmailPassword(
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
      () async => await authRemoteDataSource.signUpWithEmailPassword(
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
      if (!await connectionChecker.isConnected) {
        return left(Failure(ErrorMessages.noConnection));
      }

      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await connectionChecker.isConnected) {
        final session = authRemoteDataSource.currentUserSession;

        if (session == null) {
          return left(Failure('User not signed in!'));
        }
        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
          ),
        );
      }

      UserModel? user = await authRemoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User is not signed in.'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(ErrorMessages.noConnection));
      }
      return right(authRemoteDataSource.signOut());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
