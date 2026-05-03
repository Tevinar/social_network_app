import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_feed/blog_feed_bloc.dart';

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
    'given BlogsLoading when copyWith is called then returns BlogsLoading '
    'with updated values',
    () {
      // Arrange
      const state = BlogsLoading(blogs: [], pageNumber: 1);

      // Act
      final result = state.copyWith(
        blogs: [blog],
        pageNumber: 2,
        totalBlogsInDatabase: 4,
      );

      // Assert
      expect(result, isA<BlogsLoading>());
      expect(result.blogs, [blog]);
      expect(result.pageNumber, 2);
      expect(result.totalBlogsInDatabase, 4);
    },
  );

  test(
    'given BlogsLoading when copyWith omits blogs and totalBlogsInDatabase '
    'then it preserves existing values',
    () {
      // Arrange
      final state = BlogsLoading(
        blogs: [blog],
        pageNumber: 1,
        totalBlogsInDatabase: 4,
      );

      // Act
      final result = state.copyWith(pageNumber: 2);

      // Assert
      expect(result, isA<BlogsLoading>());
      expect(result.blogs, [blog]);
      expect(result.pageNumber, 2);
      expect(result.totalBlogsInDatabase, 4);
    },
  );

  test(
    'given BlogsSuccess when copyWith is called then returns BlogsSuccess '
    'with updated values',
    () {
      // Arrange
      const state = BlogsSuccess(blogs: [], pageNumber: 1);

      // Act
      final result = state.copyWith(
        blogs: [blog],
        pageNumber: 2,
        totalBlogsInDatabase: 4,
      );

      // Assert
      expect(result, isA<BlogsSuccess>());
      expect(result.blogs, [blog]);
      expect(result.pageNumber, 2);
      expect(result.totalBlogsInDatabase, 4);
    },
  );

  test(
    'given BlogsFailure when copyWith is called then preserves the error '
    'and updates other values',
    () {
      // Arrange
      const state = BlogsFailure(
        error: 'boom',
        blogs: [],
        pageNumber: 1,
      );

      // Act
      final result = state.copyWith(
        blogs: [blog],
        pageNumber: 2,
        totalBlogsInDatabase: 4,
      );

      // Assert
      expect(result, isA<BlogsFailure>());
      expect((result as BlogsFailure).error, 'boom');
      expect(result.blogs, [blog]);
      expect(result.pageNumber, 2);
      expect(result.totalBlogsInDatabase, 4);
    },
  );

  test(
    'given BlogsFailure when copyWith omits optional values then it '
    'preserves existing values',
    () {
      // Arrange
      final state = BlogsFailure(
        error: 'boom',
        blogs: [blog],
        pageNumber: 1,
        totalBlogsInDatabase: 4,
      );

      // Act
      final result = state.copyWith();

      // Assert
      expect(result, isA<BlogsFailure>());
      expect((result as BlogsFailure).error, 'boom');
      expect(result.blogs, [blog]);
      expect(result.pageNumber, 1);
      expect(result.totalBlogsInDatabase, 4);
    },
  );
}
