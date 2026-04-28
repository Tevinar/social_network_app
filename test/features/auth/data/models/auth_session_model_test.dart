import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';

void main() {
  const user = UserModel(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  final session = AuthSessionModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    accessTokenExpiresAt: DateTime.utc(2026),
    refreshTokenExpiresAt: DateTime.utc(2026, 2),
    user: user,
  );

  final sessionJson = <String, dynamic>{
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'accessTokenExpiresAt': '2026-01-01T00:00:00.000Z',
    'refreshTokenExpiresAt': '2026-02-01T00:00:00.000Z',
    'user': <String, dynamic>{
      'id': '123',
      'name': 'Test User',
      'email': 'test@test.com',
    },
  };

  group('AuthSessionModel.fromJson', () {
    test(
      'given a session json when fromJson is called then returns a matching '
      'AuthSessionModel',
      () {
        // Act
        final result = AuthSessionModel.fromJson(sessionJson);

        // Assert
        expect(result.accessToken, 'access-token');
        expect(result.refreshToken, 'refresh-token');
        expect(result.accessTokenExpiresAt, DateTime.utc(2026));
        expect(result.refreshTokenExpiresAt, DateTime.utc(2026, 2));
        expect(result.user.id, '123');
        expect(result.user.name, 'Test User');
        expect(result.user.email, 'test@test.com');
      },
    );
  });

  group('toJson', () {
    test(
      'given an AuthSessionModel when toJson is called then returns a '
      'serializable map',
      () {
        // Act
        final result = session.toJson();

        // Assert
        expect(result, equals(sessionJson));
      },
    );
  });
}
