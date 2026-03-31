import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/data_sources/'
    'auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseUser extends Mock implements User {}

class MockAuthState extends Mock implements AuthState {}

class MockSession extends Mock implements Session {}

void main() {
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late MockSupabaseUser supabaseUser;
  late AuthRemoteDataSourceSupabaseImpl dataSource;

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    supabaseUser = MockSupabaseUser();
    dataSource = AuthRemoteDataSourceSupabaseImpl(supabase);
    when(() => supabase.auth).thenReturn(auth);
  });

  group('signInWithEmailPassword', () {
    test(
      'given an authenticated user when signInWithEmailPassword is called '
      'then returns a UserModel',
      () async {
        // Arrange
        final userJson = <String, dynamic>{
          'id': '123',
          'email': 'test@test.com',
          'user_metadata': <String, dynamic>{'name': 'Test User'},
        };
        when(() => supabaseUser.toJson()).thenReturn(userJson);
        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse(user: supabaseUser));

        // Act
        final result = await dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(
          result,
          isA<UserModel>()
              .having((u) => u.id, 'id', '123')
              .having((u) => u.name, 'name', 'Test User')
              .having((u) => u.email, 'email', 'test@test.com'),
        );
      },
    );

    test(
      'given no authenticated user when signInWithEmailPassword is called '
      'then throws ServerException',
      () async {
        // Arrange
        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse());

        // Act
        final result = dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'given an unexpected backend error when signInWithEmailPassword is '
      'called then throws ServerException',
      () async {
        // Arrange
        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('error'));

        // Act
        final result = dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'given a network error when signInWithEmailPassword is called then '
      'throws NetworkException',
      () async {
        // Arrange
        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const SocketException('No internet'));

        // Act
        final result = dataSource.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('signUpWithEmailPassword', () {
    test(
      'given an authenticated user when signUpWithEmailPassword is called '
      'then returns a UserModel',
      () async {
        // Arrange
        final userJson = <String, dynamic>{
          'id': '123',
          'email': 'test@test.com',
          'user_metadata': <String, dynamic>{'name': 'Test User'},
        };
        when(() => supabaseUser.toJson()).thenReturn(userJson);
        when(
          () => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => AuthResponse(user: supabaseUser));

        // Act
        final result = await dataSource.signUpWithEmailPassword(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(
          result,
          isA<UserModel>()
              .having((u) => u.id, 'id', '123')
              .having((u) => u.name, 'name', 'Test User')
              .having((u) => u.email, 'email', 'test@test.com'),
        );
      },
    );

    test(
      'given no authenticated user when signUpWithEmailPassword is called '
      'then throws ServerException',
      () async {
        // Arrange
        when(
          () => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => AuthResponse());

        // Act
        final result = dataSource.signUpWithEmailPassword(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'given an unexpected backend error when signUpWithEmailPassword is '
      'called then throws ServerException',
      () async {
        // Arrange
        when(
          () => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenThrow(Exception('error'));

        // Act
        final result = dataSource.signUpWithEmailPassword(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'given a network error when signUpWithEmailPassword is called then '
      'throws NetworkException',
      () async {
        // Arrange
        when(
          () => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenThrow(const SocketException('No internet'));

        // Act
        final result = dataSource.signUpWithEmailPassword(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('signOut', () {
    test(
      'given signOut succeeds when signOut is called then completes',
      () async {
        // Arrange
        when(() => auth.signOut()).thenAnswer((_) async {});

        // Act
        final result = dataSource.signOut();

        // Assert
        await expectLater(result, completes);
      },
    );

    test(
      'given an unexpected backend error when signOut is called then throws '
      'ServerException',
      () async {
        // Arrange
        when(() => auth.signOut()).thenThrow(Exception('error'));

        // Act
        final result = dataSource.signOut();

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'given a network error when signOut is called then throws '
      'NetworkException',
      () async {
        // Arrange
        when(
          () => auth.signOut(),
        ).thenThrow(const SocketException('No internet'));

        // Act
        final result = dataSource.signOut();

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('authStateChanges', () {
    test(
      'given an authenticated session when authStateChanges is listened to '
      'then emits a UserModel',
      () async {
        // Arrange
        final authState = MockAuthState();
        final session = MockSession();
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));
        when(() => authState.session).thenReturn(session);
        when(() => session.user).thenReturn(supabaseUser);
        when(() => supabaseUser.toJson()).thenReturn(<String, dynamic>{
          'id': '123',
          'email': 'test@test.com',
          'user_metadata': <String, dynamic>{'name': 'Test User'},
        });

        // Act
        final stream = dataSource.authStateChanges();

        // Assert
        await expectLater(
          stream,
          emitsInOrder([
            isA<UserModel>()
                .having((u) => u.id, 'id', '123')
                .having((u) => u.name, 'name', 'Test User')
                .having((u) => u.email, 'email', 'test@test.com'),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given a null session when authStateChanges is listened to then emits '
      'null',
      () async {
        // Arrange
        final authState = MockAuthState();
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));
        when(() => authState.session).thenReturn(null);

        // Act
        final stream = dataSource.authStateChanges();

        // Assert
        await expectLater(stream, emitsInOrder([isNull, emitsDone]));
      },
    );

    test(
      'given an upstream stream error when authStateChanges is listened to '
      'then forwards the error',
      () async {
        // Arrange
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => Stream.error(Exception('stream error')));

        // Act
        final stream = dataSource.authStateChanges();

        // Assert
        await expectLater(stream, emitsError(isA<Exception>()));
      },
    );
  });
}
