import 'dart:async';

import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloc_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:bloc_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:bloc_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSignIn extends Mock implements UserSignIn {}

class MockUserSignUp extends Mock implements UserSignUp {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockUserSignIn userSignIn;
  late MockUserSignUp userSignUp;
  late MockAuthRepository authRepository;

  final testUser = User(id: '123', name: 'Test User', email: 'test@test.com');

  setUp(() {
    userSignIn = MockUserSignIn();
    userSignUp = MockUserSignUp();
    authRepository = MockAuthRepository();

    // Default: auth stream emits nothing
    when(
      () => authRepository.authStateChanges(),
    ).thenAnswer((_) => const Stream.empty());
  });

  setUpAll(() {
    registerFallbackValue(UserSignInParams(email: '', password: ''));
    registerFallbackValue(UserSignUpParams(name: '', email: '', password: ''));
  });

  group('AuthBloc – sign in', () {
    blocTest<AuthBloc, AuthState>(
      'Given sign-in succeeds When adding AuthSignIn Then [Loading, SignedIn] is emitted',
      build: () {
        when(() => userSignIn(any())).thenAnswer((_) async => Right(testUser));

        return AuthBloc(
          userSignIn: userSignIn,
          userSignUp: userSignUp,
          authRepository: authRepository,
        );
      },
      act: (bloc) =>
          bloc.add(AuthSignIn(email: 'test@test.com', password: 'password')),
      expect: () => [AuthLoading(), AuthSignedIn(testUser)],
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
      'Given sign-in fails When adding AuthSignIn Then [Loading, Failure] is emitted',
      build: () {
        when(
          () => userSignIn(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure()));

        return AuthBloc(
          userSignIn: userSignIn,
          userSignUp: userSignUp,
          authRepository: authRepository,
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
      'Given sign-up succeeds When adding AuthSignup Then [Loading, SignedIn] is emitted',
      build: () {
        when(() => userSignUp(any())).thenAnswer((_) async => Right(testUser));

        return AuthBloc(
          userSignIn: userSignIn,
          userSignUp: userSignUp,
          authRepository: authRepository,
        );
      },
      act: (bloc) => bloc.add(
        AuthSignup(
          name: 'Test User',
          email: 'test@test.com',
          password: 'password',
        ),
      ),
      expect: () => [AuthLoading(), AuthSignedIn(testUser)],
    );
  });

  group('AuthBloc – auth state stream', () {
    blocTest<AuthBloc, AuthState>(
      'Given authStateChanges emits null When listening to auth stream Then SignedOut is emitted',
      build: () {
        when(
          () => authRepository.authStateChanges(),
        ).thenAnswer((_) => Stream.value(const Right(null)));

        return AuthBloc(
          userSignIn: userSignIn,
          userSignUp: userSignUp,
          authRepository: authRepository,
        );
      },
      expect: () => [AuthSignedOut()],
    );

    blocTest<AuthBloc, AuthState>(
      'Given authStateChanges emits a user When listening to auth stream Then SignedIn is emitted',
      build: () {
        when(
          () => authRepository.authStateChanges(),
        ).thenAnswer((_) => Stream.value(Right(testUser)));

        return AuthBloc(
          userSignIn: userSignIn,
          userSignUp: userSignUp,
          authRepository: authRepository,
        );
      },
      expect: () => [AuthSignedIn(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'Given authStateChanges emits a failure When listening to auth stream Then Failure is emitted',
      build: () {
        when(
          () => authRepository.authStateChanges(),
        ).thenAnswer((_) => Stream.value(const Left(NetworkFailure())));

        return AuthBloc(
          userSignIn: userSignIn,
          userSignUp: userSignUp,
          authRepository: authRepository,
        );
      },
      expect: () => [const AuthFailure('No internet connection.')],
    );
  });
}
