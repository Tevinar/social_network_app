import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card.dart';

void main() {
  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: List.filled(220, 'word').join(' '),
    imageUrl: 'https://image',
    topics: const [BlogTopic.technology, BlogTopic.programming],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  testWidgets(
    'given a blog when BlogCard is rendered then it shows its topics title '
    'and reading time',
    (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlogCard(blog: blog, color: Colors.blue),
          ),
        ),
      );

      // Assert
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('Programming'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('1 min'), findsOneWidget);
    },
  );

  testWidgets(
    'given a blog card when it is tapped then it navigates to BlogViewerPage',
    (tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/blogs',
        routes: [
          GoRoute(
            path: '/blogs',
            builder: (context, state) => Scaffold(
              body: BlogCard(blog: blog, color: Colors.blue),
            ),
          ),
          GoRoute(
            path: '/blog-viewer',
            builder: (context, state) => const Scaffold(body: Text('Viewer')),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.byType(BlogCard));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Viewer'), findsOneWidget);
    },
  );
}
