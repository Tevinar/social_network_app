import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/core/local_database/app_settings_store.dart';
import 'package:social_app/core/local_database/schema/app_settings.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:uuid/uuid.dart';

/// Refreshes the authenticated backend session through the backend API.
class BackendAuthSessionRefresher {
  /// Creates a [BackendAuthSessionRefresher].
  const BackendAuthSessionRefresher({
    required Dio dio,
    required AppSettingsStore appSettingsStore,
    required AuthSessionStore authSessionStore,
  }) : _dio = dio,
       _appSettingsStore = appSettingsStore,
       _authSessionStore = authSessionStore;

  final Dio _dio;
  final AppSettingsStore _appSettingsStore;
  final AuthSessionStore _authSessionStore;

  /// Requests a fresh authenticated session from the backend.
  Future<AuthSessionModel> refreshSession() {
    return guardRemoteDataSourceCall(() async {
      final session = await _authSessionStore.getSession();
      if (session == null) {
        throw const UnauthorizedException(
          message: 'Missing auth session',
        );
      }

      final deviceId = await _appSettingsStore.getOrCreate(
        key: AppSettingKey.deviceId,
        create: const Uuid().v4,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refreshToken': session.refreshToken,
          'deviceId': deviceId,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(
          message: 'Refresh session response body is empty',
        );
      }

      final refreshedSession = AuthSessionModel.fromJson(body);
      await _authSessionStore.saveSession(refreshedSession);
      return refreshedSession;
    });
  }
}
