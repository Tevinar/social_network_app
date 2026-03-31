import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_editor.dart';

void main() {
  group('BlogEditor', () {
    testWidgets('renders the provided hint text', (tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlogEditor(controller: controller, hintText: 'Blog title'),
          ),
        ),
      );

      // Assert
      expect(find.text('Blog title'), findsOneWidget);
    });

    testWidgets('uses the provided controller', (tester) async {
      // Arrange
      final controller = TextEditingController(text: 'initial');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlogEditor(controller: controller, hintText: 'Blog title'),
          ),
        ),
      );

      // Assert
      final textFormField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textFormField.controller, controller);
      expect(controller.text, 'initial');
    });

    testWidgets(
      'returns an error when validator receives an empty value',
      (tester) async {
        // Arrange
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlogEditor(controller: controller, hintText: 'Blog title'),
            ),
          ),
        );

        // Act
        final field = tester.widget<TextFormField>(find.byType(TextFormField));
        final result = field.validator?.call('');

        // Assert
        expect(result, 'Blog title is missing');
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
              body: BlogEditor(controller: controller, hintText: 'Blog title'),
            ),
          ),
        );

        // Act
        final field = tester.widget<TextFormField>(find.byType(TextFormField));
        final result = field.validator?.call('Title');

        // Assert
        expect(result, isNull);
      },
    );
  });
}
