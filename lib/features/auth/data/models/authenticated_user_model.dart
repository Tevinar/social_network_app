import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';

/// Data model returned by sign-in and sign-up endpoints.
class AuthenticatedUserModel {
  /// Creates an [AuthenticatedUserModel].
  const AuthenticatedUserModel({
    required this.session,
    required this.user,
  });

  /// Creates an [AuthenticatedUserModel] from a JSON map.
  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserModel(
      session: AuthSessionModel.fromJson(json),
      user: UserModel.fromJson(JsonReader.readObject(json, 'user')),
    );
  }

  /// Authenticated token session returned by the backend.
  final AuthSessionModel session;

  /// Signed-in user associated with [session].
  final UserModel user;
}
