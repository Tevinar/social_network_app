import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';

void main() {
  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image.test/blog-1.png',
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  test(
    'creates a cache snapshot with an optional refresh failure',
    () {
      const refreshFailure = ValidationFailure('offline');
      final snapshot = BlogSnapshot(
        blog: blog,
        source: BlogSource.cache,
        refreshFailure: refreshFailure,
      );

      expect(snapshot.blog, blog);
      expect(snapshot.source, BlogSource.cache);
      expect(snapshot.refreshFailure, refreshFailure);
    },
  );

  test(
    'creates a remote snapshot without a refresh failure by default',
    () {
      final snapshot = BlogSnapshot(
        blog: blog,
        source: BlogSource.remote,
      );

      expect(snapshot.source, BlogSource.remote);
      expect(snapshot.refreshFailure, isNull);
    },
  );
}
