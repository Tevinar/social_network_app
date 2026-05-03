import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';

void main() {
  final blogs = [
    Blog(
      id: 'blog-1',
      posterId: 'user-1',
      title: 'Title',
      content: 'Content',
      imageUrl: 'https://image.test/blog-1.png',
      topics: const [BlogTopic.technology],
      updatedAt: DateTime(2025),
      posterName: 'Alice',
    ),
  ];

  test(
    'creates a page snapshot with page number, source, blogs and refresh '
    'failure',
    () {
      const refreshFailure = ValidationFailure('stale');
      final snapshot = BlogsPageSnapshot(
        pageNumber: 2,
        blogs: blogs,
        source: BlogsPageSource.cache,
        refreshFailure: refreshFailure,
      );

      expect(snapshot.pageNumber, 2);
      expect(snapshot.blogs, blogs);
      expect(snapshot.source, BlogsPageSource.cache);
      expect(snapshot.refreshFailure, refreshFailure);
    },
  );

  test(
    'creates a remote page snapshot without a refresh failure by default',
    () {
      final snapshot = BlogsPageSnapshot(
        pageNumber: 1,
        blogs: blogs,
        source: BlogsPageSource.remote,
      );

      expect(snapshot.pageNumber, 1);
      expect(snapshot.source, BlogsPageSource.remote);
      expect(snapshot.refreshFailure, isNull);
    },
  );
}
