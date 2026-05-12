import 'package:social_app/core/serialization/json_reader.dart';

/// Data model representing a locally persisted authenticated token session.
class AuthSessionModel {
  /// Creates an [AuthSessionModel].
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  /// Creates an [AuthSessionModel] from a JSON map.
  factory AuthSessionModel.fromJson(Map<String, dynamic> map) {
    return AuthSessionModel(
      accessToken: JsonReader.readString(map, 'accessToken'),
      refreshToken: JsonReader.readString(map, 'refreshToken'),
      accessTokenExpiresAt: JsonReader.readDateTime(
        map,
        'accessTokenExpiresAt',
      ),
      refreshTokenExpiresAt: JsonReader.readDateTime(
        map,
        'refreshTokenExpiresAt',
      ),
    );
  }

  /// Short-lived token used to authorize backend API requests.
  final String accessToken;

  /// Long-lived token used to renew the authenticated session.
  final String refreshToken;

  /// Expiration timestamp for [accessToken].
  final DateTime accessTokenExpiresAt;

  /// Expiration timestamp for [refreshToken].
  final DateTime refreshTokenExpiresAt;

  /// Converts the model to a serializable JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
    };
  }
}
