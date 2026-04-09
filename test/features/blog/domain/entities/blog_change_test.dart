import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';

void main() {
  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  test(
    'given a blog when BlogInserted is created then exposes the blog',
    () {
      // Act
      final change = BlogInserted(blog);

      // Assert
      expect(change.blog, blog);
    },
  );

  test(
    'given a blog when BlogUpdated is created then exposes the blog',
    () {
      // Act
      final change = BlogUpdated(blog);

      // Assert
      expect(change.blog, blog);
    },
  );

  test(
    'given a blog id when BlogDeleted is created then exposes the id',
    () {
      // Act
      final change = BlogDeleted('blog-1');

      // Assert
      expect(change.blogId, 'blog-1');
    },
  );
}
