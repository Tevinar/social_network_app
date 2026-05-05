import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/core/local_database/app_settings_store.dart';
import 'package:social_app/core/local_database/schema/app_settings.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:social_app/features/auth/data/models/authenticated_user_model.dart';
import 'package:uuid/uuid.dart';

/// Remote boundary for backend authentication requests.
abstract interface class AuthRemoteDataSource {
  /// Registers a user through the backend and returns the authenticated user
  /// payload.
  Future<AuthenticatedUserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  /// Authenticates a user through the backend and returns the signed-in user
  /// payload.
  Future<AuthenticatedUserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Revokes the current backend refresh session.
  Future<void> signOut();
}

/// Dio-backed implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Creates a backend auth data source.
  ///
  /// [dio] must be configured with the backend base URL. [appSettingsStore]
  /// provides the stable device identifier required by the auth API, and
  /// [authSessionStore] provides the refresh token required by sign-out.
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
  Future<AuthenticatedUserModel> signInWithEmailPassword({
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

      return AuthenticatedUserModel.fromJson(body);
    });
  }

  @override
  Future<AuthenticatedUserModel> signUpWithEmailPassword({
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

      return AuthenticatedUserModel.fromJson(body);
    });
  }

  @override
  Future<void> signOut() async {
    return guardRemoteDataSourceCall(() async {
      final session = await _authSessionStore.getSession();

      if (session == null) {
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
    });
  }
}
