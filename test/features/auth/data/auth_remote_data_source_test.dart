import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/data_sources/auth_remote_data_source.dart';
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
  late AuthRemoteDataSourceSupabaseImpl ds;

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    supabaseUser = MockSupabaseUser();
    ds = AuthRemoteDataSourceSupabaseImpl(supabase);
    when(() => supabase.auth).thenReturn(auth);
  });
  group('signInWithEmailPassword', () {
    test(
      'Given Supabase returns a user When signing in with email and password Then a UserModel is returned',
      () async {
        // Arrange
        final userJson = {'id': '123', 'email': 'test@test.com'};
        when(() => supabaseUser.toJson()).thenReturn(userJson);
        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse(user: supabaseUser));

        // Act
        final result = await ds.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(
          result,
          isA<UserModel>()
              .having((u) => u.id, 'id', '123')
              .having((u) => u.name, 'name', '')
              .having((u) => u.email, 'email', 'test@test.com'),
        );
      },
    );

    test(
      'Given Supabase returns null When signing in with email and password Then a ServerException is thrown',
      () async {
        // Arrange

        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse());

        // Act
        final result = ds.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'Given Supabase throws an exception When signing in with email and password Then a ServerException is thrown',
      () async {
        // Arrange
        when(
          () => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Supabase error'));

        // Act
        final result = ds.signInWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
        );

        // Assert
        expect(result, throwsA(isA<ServerException>()));
      },
    );
  });

  group('signUpWithEmailPassword', () {
    test(
      'Given Supabase returns a user When signing up with email and password Then a UserModel is returned',
      () async {
        // Arrange
        final userJson = <String, Object>{
          'id': '123',
          'email': 'test@test.com',
          'user_metadata': {'name': 'Test User'},
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
        final result = await ds.signUpWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
          name: 'Test User',
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
      'Given Supabase returns null When signing up with email and password Then a ServerException is thrown',
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
        final result = ds.signUpWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
          name: 'Test User',
        );

        // Assert
        expect(result, throwsA(isA<ServerException>()));
      },
    );

    test(
      'Given Supabase throws an exception When signing up with email and password Then a ServerException is thrown',
      () async {
        // Arrange
        when(
          () => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenThrow(Exception('Supabase error'));

        // Act
        final result = ds.signUpWithEmailPassword(
          email: 'test@test.com',
          password: 'password',
          name: 'Test User',
        );

        // Assert
        expect(result, throwsA(isA<ServerException>()));
      },
    );
  });

  group('signOut', () {
    test(
      'Given Supabase signs out When signing out Then it completes',
      () async {
        // Arrange
        when(() => auth.signOut()).thenAnswer((_) async {});

        // Act
        await ds.signOut();

        // Assert
        verify(() => auth.signOut()).called(1);
      },
    );

    test(
      'Given Supabase throws an exception When signing out Then a ServerException is thrown',
      () async {
        // Arrange
        when(() => auth.signOut()).thenThrow(Exception('Supabase error'));

        // Act
        final result = ds.signOut();

        // Assert
        expect(result, throwsA(isA<ServerException>()));
      },
    );
  });

  group('authStateChanges', () {
    test(
      'Given Supabase emits an auth state with a user When listening to auth changes Then a UserModel is returned',
      () async {
        final authState = MockAuthState();
        // Arrange
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));

        final session = MockSession();
        when(() => authState.session).thenReturn(session);
        when(() => session.user).thenReturn(supabaseUser);
        when(
          () => supabaseUser.toJson(),
        ).thenReturn({'id': '123', 'email': 'test@test.com'});

        // Act
        final stream = ds.authStateChanges();

        // Assert
        await expectLater(
          stream,
          emitsInOrder([
            isA<UserModel>()
                .having((u) => u.id, 'id', '123')
                .having((u) => u.name, 'name', '')
                .having((u) => u.email, 'email', 'test@test.com'),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'Given Supabase emits an auth state with a null session When listening to auth changes Then null is returned',
      () async {
        final authState = MockAuthState();
        // Arrange
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));

        when(() => authState.session).thenReturn(null);

        // Act
        final stream = ds.authStateChanges();

        // Assert
        await expectLater(stream, emitsInOrder([isNull, emitsDone]));
      },
    );

    test(
      'Given Supabase emits an auth state with a null session When listening to auth changes Then null is returned',
      () async {
        final authState = MockAuthState();
        // Arrange
        when(
          () => auth.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));

        when(() => authState.session).thenReturn(null);

        // Act
        final stream = ds.authStateChanges();

        // Assert
        await expectLater(stream, emitsInOrder([isNull, emitsDone]));
      },
    );
  });
}
