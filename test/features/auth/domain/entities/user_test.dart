import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';

void main() {
  group('User', () {
    test(
      'given constructor values when User is created then exposes the '
      'provided fields',
      () {
        // Arrange
        const id = '123';
        const name = 'Test User';
        const email = 'test@test.com';

        // Act
        const user = UserEntity(id: id, name: name, email: email);

        // Assert
        expect(user.id, id);
        expect(user.name, name);
        expect(user.email, email);
      },
    );

    test(
      'given a User when toString is called then returns the display name',
      () {
        // Arrange
        const user = UserEntity(
          id: '123',
          name: 'Test User',
          email: 'test@test.com',
        );

        // Act
        final result = user.toString();

        // Assert
        expect(result, 'Test User');
      },
    );
  });
}
