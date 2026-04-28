import 'package:social_app/features/auth/data/models/user_model.dart';

/// Data model representing a locally persisted authenticated session.
class AuthSessionModel {
  /// Creates an [AuthSessionModel].
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  /// Creates an [AuthSessionModel] from a JSON map.
  factory AuthSessionModel.fromJson(Map<String, dynamic> map) {
    return AuthSessionModel(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        map['accessTokenExpiresAt'] as String,
      ),
      refreshTokenExpiresAt: DateTime.parse(
        map['refreshTokenExpiresAt'] as String,
      ),
      user: UserModel.fromJson(map['user'] as Map<String, dynamic>),
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

  /// Authenticated user associated with this session.
  final UserModel user;

  /// Converts the model to a serializable JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
