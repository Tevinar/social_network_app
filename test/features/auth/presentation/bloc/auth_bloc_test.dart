import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_up_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/watch_auth_state_changes_use_case.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockUserSignIn extends Mock implements UserSignInUseCase {}

class MockUserSignUp extends Mock implements UserSignUpUseCase {}

class MockWatchAuthStateChanges extends Mock implements WatchAuthStateChanges {}

void main() {
  late MockUserSignIn userSignIn;
  late MockUserSignUp userSignUp;
  late MockWatchAuthStateChanges watchAuthStateChanges;

  const testUser = UserEntity(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  setUp(() {
    userSignIn = MockUserSignIn();
    userSignUp = MockUserSignUp();
    watchAuthStateChanges = MockWatchAuthStateChanges();

    // Default: auth stream emits nothing
    when(() => watchAuthStateChanges()).thenAnswer(
      (_) => const Stream.empty(),
    );
    registerFallbackValue(UserSignInParams(email: '', password: ''));
    registerFallbackValue(UserSignUpParams(name: '', email: '', password: ''));
  });

  group('AuthBloc – sign in', () {
    blocTest<AuthBloc, AuthState>(
      'Given sign-in succeeds when adding AuthSignIn, then '
      '[Loading, SignedIn] is emitted',
      build: () {
        when(
          () => userSignIn(any()),
        ).thenAnswer((_) async => const Right(testUser));

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      act: (bloc) =>
          bloc.add(AuthSignIn(email: 'test@test.com', password: 'password')),
      expect: () => [AuthLoading(), const AuthSignedIn(testUser)],
      verify: (_) {
        verify(
          () => userSignIn(
            any(
              that: isA<UserSignInParams>()
                  .having((p) => p.email, 'email', 'test@test.com')
                  .having((p) => p.password, 'password', 'password'),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'Given sign-in fails when adding AuthSignIn, then '
      '[Loading, Failure] is emitted',
      build: () {
        when(
          () => userSignIn(any()),
        ).thenAnswer((_) async => left(const NetworkFailure()));

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      act: (bloc) =>
          bloc.add(AuthSignIn(email: 'test@test.com', password: 'password')),
      expect: () => [
        AuthLoading(),
        const AuthFailure('No internet connection.'),
      ],
    );
  });

  group('AuthBloc – sign up', () {
    blocTest<AuthBloc, AuthState>(
      'Given sign-up succeeds when adding AuthSignup, then '
      '[Loading, SignedIn] is emitted',
      build: () {
        when(
          () => userSignUp(any()),
        ).thenAnswer((_) async => const Right(testUser));

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      act: (bloc) => bloc.add(
        AuthSignup(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        ),
      ),
      expect: () => [AuthLoading(), const AuthSignedIn(testUser)],
      verify: (_) {
        verify(
          () => userSignUp(
            any(
              that: isA<UserSignUpParams>()
                  .having((p) => p.name, 'name', 'Test User')
                  .having((p) => p.email, 'email', 'test@test.com')
                  .having((p) => p.password, 'password', 'password'),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'Given sign-up fails when adding AuthSignup, then '
      '[Loading, Failure] is emitted',
      build: () {
        when(
          () => userSignUp(any()),
        ).thenAnswer(
          (_) async => left(const ValidationFailure('Invalid data')),
        );

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      act: (bloc) => bloc.add(
        AuthSignup(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        ),
      ),
      expect: () => [AuthLoading(), const AuthFailure('Invalid data')],
    );
  });

  group('AuthBloc – auth state stream', () {
    blocTest<AuthBloc, AuthState>(
      'Given authStateChanges emits null when listening to the auth stream, '
      'then SignedOut is emitted',
      build: () {
        when(() => watchAuthStateChanges()).thenAnswer(
          (_) => Stream.value(const Right(null)),
        );

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      expect: () => [AuthSignedOut()],
    );

    blocTest<AuthBloc, AuthState>(
      'Given authStateChanges emits a user when listening to the auth '
      'stream, then SignedIn is emitted',
      build: () {
        when(() => watchAuthStateChanges()).thenAnswer(
          (_) => Stream.value(const Right(testUser)),
        );

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      expect: () => [const AuthSignedIn(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'Given authStateChanges emits a failure when listening to the auth '
      'stream, then Failure is emitted',
      build: () {
        when(() => watchAuthStateChanges()).thenAnswer(
          (_) => Stream.value(left(const NetworkFailure())),
        );

        return AuthBloc(
          userSignInUseCase: userSignIn,
          userSignUpUseCase: userSignUp,
          watchAuthStateChangesUseCase: watchAuthStateChanges,
        );
      },
      expect: () => [const AuthFailure('No internet connection.')],
    );
  });
}
