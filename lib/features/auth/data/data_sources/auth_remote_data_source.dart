import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/core/local_database/app_settings_store.dart';
import 'package:social_app/core/local_database/schema/app_settings.dart';
import 'package:social_app/features/auth/data/data_sources/auth_session_store.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:uuid/uuid.dart';

/// Remote boundary for backend authentication requests.
abstract interface class AuthRemoteDataSource {
  /// Registers a user through the backend and returns the authenticated user.
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  /// Authenticates a user through the backend and returns the signed-in user.
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Revokes the current backend refresh session and clears local auth state.
  Future<void> signOut();
}

/// Dio-backed implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates a backend auth data source.
  ///
  /// [dio] must be configured with the backend base URL. [appSettingsStore]
  /// provides the stable device identifier required by the auth API, and
  /// [authSessionStore] persists the token session returned by sign-in and
  /// sign-up.
  const AuthRemoteDataSourceImpl({
    required AppSettingsStore appSettingsStore,
    required Dio dio,
    required AuthSessionStore authSessionStore,
  }) : _appSettingsStore = appSettingsStore,
       _dio = dio,
       _authSessionStore = authSessionStore;

  final AppSettingsStore _appSettingsStore;
  final Dio _dio;
  final AuthSessionStore _authSessionStore;

  @override
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return guardRemoteDataSourceCall(() async {
      final deviceId = await _appSettingsStore.getOrCreate(
        key: AppSettingKey.deviceId,
        create: const Uuid().v4,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/sign-in',
        data: {
          'email': email,
          'password': password,
          'deviceId': deviceId,
        },
      );

      final body = response.data;

      if (body == null) {
        throw const ServerException(message: 'Sign in response body is empty');
      }

      final userJson = body['user'];

      if (userJson is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Sign in response user is invalid',
        );
      }

      await _authSessionStore.saveSession(
        AuthSessionModel.fromJson(body),
      );

      return UserModel.fromJson(userJson);
    });
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return guardRemoteDataSourceCall(() async {
      final deviceId = await _appSettingsStore.getOrCreate(
        key: AppSettingKey.deviceId,
        create: const Uuid().v4,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/sign-up',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'deviceId': deviceId,
        },
      );

      final body = response.data;

      if (body == null) {
        throw const ServerException(message: 'Sign up response body is empty');
      }

      final userJson = body['user'];

      if (userJson is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Sign up response user is invalid',
        );
      }

      await _authSessionStore.saveSession(
        AuthSessionModel.fromJson(body),
      );

      return UserModel.fromJson(userJson);
    });
  }

  @override
  Future<void> signOut() async {
    return guardRemoteDataSourceCall(() async {
      final session = await _authSessionStore.getSession();

      if (session == null) {
        await _authSessionStore.clearSession();
        return;
      }

      final deviceId = await _appSettingsStore.getOrCreate(
        key: AppSettingKey.deviceId,
        create: const Uuid().v4,
      );

      await _dio.post<void>(
        '/auth/sign-out',
        data: {
          'refreshToken': session.refreshToken,
          'deviceId': deviceId,
        },
      );

      await _authSessionStore.clearSession();
    });
  }
}
