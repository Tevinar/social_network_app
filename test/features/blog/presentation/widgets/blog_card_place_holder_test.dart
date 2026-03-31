import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card_place_holder.dart';

void main() {
  testWidgets(
    'given a color when BlogCardPlaceholder is rendered then applies the color',
    (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlogCardPlaceholder(color: AppPallete.gradient1),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppPallete.gradient1);
      expect(find.byType(Container), findsWidgets);
    },
  );
}
