import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

void main() {
  const testUser = User(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  const testUserModel = UserModel(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  group('UserModel', () {
    test(
      'given constructor parameters when UserModel is created then exposes '
      'the provided fields',
      () {
        // Arrange
        const id = '123';
        const name = 'Test User';
        const email = 'test@test.com';

        // Act
        const result = UserModel(id: id, name: name, email: email);

        // Assert
        expect(result.id, id);
        expect(result.name, name);
        expect(result.email, email);
      },
    );
  });

  group('UserModel.fromProfileJson', () {
    test(
      'given a profile json when fromProfileJson is called then returns a '
      'UserModel with an empty email',
      () {
        // Arrange
        final map = <String, dynamic>{'id': '123', 'name': 'Test User'};

        // Act
        final result = UserModel.fromProfileJson(map);

        // Assert
        expect(result.id, '123');
        expect(result.name, 'Test User');
        expect(result.email, '');
      },
    );
  });

  group('UserModel.fromEntity', () {
    test(
      'given a User entity when fromEntity is called then returns a '
      'matching UserModel',
      () {
        // Arrange
        const user = testUser;

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result.id, testUser.id);
        expect(result.name, testUser.name);
        expect(result.email, testUser.email);
      },
    );
  });

  group('UserModel.fromAuthJson', () {
    test(
      'given an auth json with user metadata when fromAuthJson is called '
      'then returns a matching UserModel',
      () {
        // Arrange
        final map = <String, dynamic>{
          'id': '123',
          'email': 'test@test.com',
          'user_metadata': <String, dynamic>{'name': 'Test User'},
        };

        // Act
        final result = UserModel.fromAuthJson(map);

        // Assert
        expect(result.id, '123');
        expect(result.name, 'Test User');
        expect(result.email, 'test@test.com');
      },
    );

    test(
      'given an auth json without user metadata when fromAuthJson is called '
      'then returns a UserModel with an empty name',
      () {
        // Arrange
        final map = <String, dynamic>{
          'id': '123',
          'email': 'test@test.com',
        };

        // Act
        final result = UserModel.fromAuthJson(map);

        // Assert
        expect(result.id, '123');
        expect(result.name, '');
        expect(result.email, 'test@test.com');
      },
    );

    test(
      'given an auth json with user metadata without a name when '
      'fromAuthJson is called then returns a UserModel with an empty name',
      () {
        // Arrange
        final map = <String, dynamic>{
          'id': '123',
          'email': 'test@test.com',
          'user_metadata': <String, dynamic>{'name': null},
        };

        // Act
        final result = UserModel.fromAuthJson(map);

        // Assert
        expect(result.id, '123');
        expect(result.name, '');
        expect(result.email, 'test@test.com');
      },
    );
  });

  group('toJson', () {
    test(
      'given a UserModel when toJson is called then returns a serializable '
      'map',
      () {
        // Arrange
        const userModel = testUserModel;

        // Act
        final result = userModel.toJson();

        // Assert
        expect(
          result,
          equals(<String, dynamic>{
            'id': '123',
            'name': 'Test User',
            'email': 'test@test.com',
          }),
        );
      },
    );
  });

  group('copyWith', () {
    test(
      'given a UserModel when copyWith is called with new values then '
      'returns a copied model with updated fields',
      () {
        // Arrange
        const userModel = testUserModel;

        // Act
        final result = userModel.copyWith(
          id: '456',
          name: 'Updated User',
          email: 'updated@test.com',
        );

        // Assert
        expect(result.id, '456');
        expect(result.name, 'Updated User');
        expect(result.email, 'updated@test.com');
      },
    );

    test(
      'given a UserModel when copyWith is called without all fields then '
      'preserves the existing values',
      () {
        // Arrange
        const userModel = testUserModel;

        // Act
        final result = userModel.copyWith(name: 'Updated User');

        // Assert
        expect(result.id, '123');
        expect(result.name, 'Updated User');
        expect(result.email, 'test@test.com');
      },
    );

    test(
      'given a UserModel when copyWith is called without a name then '
      'preserves the existing name',
      () {
        // Arrange
        const userModel = testUserModel;

        // Act
        final result = userModel.copyWith(email: 'updated@test.com');

        // Assert
        expect(result.id, '123');
        expect(result.name, 'Test User');
        expect(result.email, 'updated@test.com');
      },
    );
  });

  group('toEntity', () {
    test(
      'given a UserModel when toEntity is called then returns a matching '
      'User entity',
      () {
        // Arrange
        const userModel = testUserModel;

        // Act
        final result = userModel.toEntity();

        // Assert
        expect(result.id, '123');
        expect(result.name, 'Test User');
        expect(result.email, 'test@test.com');
      },
    );
  });
}
