import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_app/features/auth/presentation/pages/signin_page.dart';
import 'package:social_app/features/auth/presentation/pages/signup_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    authBloc = MockAuthBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const SignUpPage(),
      ),
    );
  }

  Widget buildRoutableWidget() {
    final router = GoRouter(
      initialLocation: '/sign-up',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const SignInPage(),
          ),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const SignUpPage(),
          ),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('SignUpPage', () {
    testWidgets('renders sign-up form correctly', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(authBloc, Stream.value(AuthSignedOut()));

      // Act
      await tester.pumpWidget(buildTestableWidget());

      // Assert
      expect(find.text('Sign Up.'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('dispatches AuthSignup when form is submitted', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(authBloc, Stream.value(AuthSignedOut()));

      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  Test User  ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '  test@test.com  ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        '  password  ',
      );

      // Act
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      verify(
        () => authBloc.add(
          any(
            that: isA<AuthSignup>()
                .having((e) => e.name, 'name', 'Test User')
                .having((e) => e.email, 'email', 'test@test.com')
                .having((e) => e.password, 'password', 'password'),
          ),
        ),
      ).called(1);
    });

    testWidgets(
      'does not dispatch AuthSignup when the form is invalid',
      (tester) async {
        // Arrange
        when(() => authBloc.state).thenReturn(AuthSignedOut());
        whenListen(authBloc, Stream.value(AuthSignedOut()));

        await tester.pumpWidget(buildTestableWidget());

        // Act
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Name is missing!'), findsOneWidget);
        expect(find.text('Email is missing!'), findsOneWidget);
        expect(find.text('Password is missing!'), findsOneWidget);
        verifyNever(() => authBloc.add(any()));
      },
    );

    testWidgets('shows SnackBar when AuthFailure is emitted', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(
        authBloc,
        Stream.fromIterable([
          AuthSignedOut(),
          const AuthFailure('Email already in use'),
        ]),
      );

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('navigates to SignInPage when footer is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(authBloc, Stream.value(AuthSignedOut()));

      await tester.pumpWidget(buildRoutableWidget());

      // Act
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              (widget.text as TextSpan).toPlainText().contains(
                'Already have an account ? Sign In',
              ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SignInPage), findsOneWidget);
    });
  });
}
