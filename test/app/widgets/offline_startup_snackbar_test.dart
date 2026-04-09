import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/widgets/offline_startup_snackbar.dart';
import 'package:social_app/core/network/connection_checker.dart';

class MockConnectionChecker extends Mock implements ConnectionChecker {}

void main() {
  late MockConnectionChecker connectionChecker;

  setUp(() {
    connectionChecker = MockConnectionChecker();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: OfflineStartupSnackbar(
        connectionChecker: connectionChecker,
        child: const Scaffold(body: Text('Body')),
      ),
    );
  }

  testWidgets(
    'given the app starts offline when the widget is built then it shows '
    'the offline snackbar once',
    (tester) async {
      when(() => connectionChecker.isConnected).thenAnswer((_) async => false);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('You are offline'), findsOneWidget);
    },
  );

  testWidgets(
    'given the app starts online when the widget is built then it does not '
    'show the offline snackbar',
    (tester) async {
      when(() => connectionChecker.isConnected).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('You are offline'), findsNothing);
    },
  );
}
