import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/data/models/authenticated_user_model.dart';

void main() {
  final authenticatedUserJson = <String, dynamic>{
    'user': <String, dynamic>{
      'id': '123',
      'name': 'Test User',
      'email': 'test@test.com',
    },
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'accessTokenExpiresAt': '2026-01-01T00:00:00.000Z',
    'refreshTokenExpiresAt': '2026-02-01T00:00:00.000Z',
  };

  group('AuthenticatedUserModel.fromJson', () {
    test(
      'given an authenticated user payload when fromJson is called then '
      'returns matching session and user models',
      () {
        // Act
        final result = AuthenticatedUserModel.fromJson(authenticatedUserJson);

        // Assert
        expect(result.session.accessToken, 'access-token');
        expect(result.session.refreshToken, 'refresh-token');
        expect(result.session.accessTokenExpiresAt, DateTime.utc(2026));
        expect(result.session.refreshTokenExpiresAt, DateTime.utc(2026, 2));
        expect(result.user.id, '123');
        expect(result.user.name, 'Test User');
        expect(result.user.email, 'test@test.com');
      },
    );
  });
}
