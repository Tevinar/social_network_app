import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/presentation/widgets/auth_field.dart';

void main() {
  group('AuthField', () {
    testWidgets('renders the hint text', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthField(
              hintText: 'Email',
              controller: controller,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('uses the provided controller', (tester) async {
      // Arrange
      final controller = TextEditingController(text: 'initial value');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthField(
              hintText: 'Email',
              controller: controller,
            ),
          ),
        ),
      );

      // Assert
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.controller, controller);
      expect(controller.text, 'initial value');
    });

    testWidgets('uses obscured text when requested', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthField(
              hintText: 'Password',
              controller: controller,
              isObscureText: true,
            ),
          ),
        ),
      );

      // Assert
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isTrue);
    });

    testWidgets(
      'returns an error message when validator receives an empty value',
      (tester) async {
        // Arrange
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthField(
                hintText: 'Email',
                controller: controller,
              ),
            ),
          ),
        );

        // Act
        final textFormField = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );
        final result = textFormField.validator?.call('');

        // Assert
        expect(result, 'Email is missing!');
      },
    );

    testWidgets(
      'returns null when validator receives a non-empty value',
      (tester) async {
        // Arrange
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthField(
                hintText: 'Email',
                controller: controller,
              ),
            ),
          ),
        );

        // Act
        final textFormField = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );
        final result = textFormField.validator?.call('test@test.com');

        // Assert
        expect(result, isNull);
      },
    );
  });
}
