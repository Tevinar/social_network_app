import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

void main() {
  test(
    'given constructor values when Blog is created then exposes them',
    () {
      // Arrange
      final updatedAt = DateTime(2025);

      // Act
      final blog = Blog(
        id: 'blog-1',
        posterId: 'user-1',
        title: 'Title',
        content: 'Content',
        imageUrl: 'https://image',
        topics: const ['Tech'],
        updatedAt: updatedAt,
        posterName: 'Alice',
      );

      // Assert
      expect(blog.id, 'blog-1');
      expect(blog.posterId, 'user-1');
      expect(blog.title, 'Title');
      expect(blog.content, 'Content');
      expect(blog.imageUrl, 'https://image');
      expect(blog.topics, const ['Tech']);
      expect(blog.updatedAt, updatedAt);
      expect(blog.posterName, 'Alice');
    },
  );
}
