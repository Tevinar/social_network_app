import 'package:social_network_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_network_app/features/auth/presentation/pages/signin_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// --------------------
/// Mocks & fakes
/// --------------------

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
        child: const SignInPage(),
      ),
    );
  }

  group('SignInPage', () {
    testWidgets('renders sign-in form correctly', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(authBloc, Stream.value(AuthSignedOut()));

      // Act
      await tester.pumpWidget(buildTestableWidget());

      // Assert
      expect(find.text('Sign In.'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      final richText = tester.widget<RichText>(
        find.byKey(const Key('signup_text')),
      );
      expect((richText.text as TextSpan).toPlainText(), contains('Sign Up'));
    });

    testWidgets('dispatches AuthSignIn when form is submitted', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(authBloc, Stream.value(AuthSignedOut()));

      await tester.pumpWidget(buildTestableWidget());

      // Fill form
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');

      // Act
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      verify(
        () => authBloc.add(
          any(
            that: isA<AuthSignIn>()
                .having((e) => e.email, 'email', 'test@test.com')
                .having((e) => e.password, 'password', 'password'),
          ),
        ),
      ).called(1);
    });

    testWidgets('shows SnackBar when AuthFailure is emitted', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthSignedOut());
      whenListen(
        authBloc,
        Stream.fromIterable([
          AuthSignedOut(),
          const AuthFailure('Invalid credentials'),
        ]),
      );

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(); // process stream event
      await tester.pump(const Duration(seconds: 1)); // snackbar animation

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
