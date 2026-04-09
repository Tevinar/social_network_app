import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';

void main() {
  final updatedAt = DateTime(2025, 1, 1, 12);
  final model = BlogModel(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const [BlogTopic.technology],
    updatedAt: updatedAt,
    posterName: 'Alice',
  );

  group('BlogModel.fromSupabaseJson', () {
    test(
      'given a complete json when fromSupabaseJson is called then returns '
      'a BlogModel',
      () {
        // Arrange
        final json = <String, dynamic>{
          'id': 'blog-1',
          'poster_id': 'user-1',
          'title': 'Title',
          'content': 'Content',
          'image_url': 'https://image',
          'topics': ['Technology'],
          'updated_at': updatedAt.toIso8601String(),
          'poster_name': 'Alice',
        };

        // Act
        final result = BlogModel.fromSupabaseJson(json);

        // Assert
        expect(result.id, 'blog-1');
        expect(result.posterId, 'user-1');
        expect(result.title, 'Title');
        expect(result.content, 'Content');
        expect(result.imageUrl, 'https://image');
        expect(result.topics, const [BlogTopic.technology]);
        expect(result.updatedAt, updatedAt);
        expect(result.posterName, 'Alice');
      },
    );

    test(
      'given missing fields when fromSupabaseJson is called then uses defaults',
      () {
        // Arrange
        final before = DateTime.now();

        // Act
        final result = BlogModel.fromSupabaseJson(const <String, dynamic>{});

        // Assert
        final after = DateTime.now();
        expect(result.id, '');
        expect(result.posterId, '');
        expect(result.title, '');
        expect(result.content, '');
        expect(result.imageUrl, '');
        expect(result.topics, isEmpty);
        expect(
          result.updatedAt.isAfter(before) ||
              result.updatedAt.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          result.updatedAt.isBefore(after) ||
              result.updatedAt.isAtSameMomentAs(after),
          isTrue,
        );
      },
    );
  });

  test(
    'given a model when toSupabaseInsertJson is called then returns a '
    'serializable map',
    () {
      // Act
      final result = model.toSupabaseInsertJson();

      // Assert
      expect(result, <String, dynamic>{
        'id': 'blog-1',
        'poster_id': 'user-1',
        'title': 'Title',
        'content': 'Content',
        'image_url': 'https://image',
        'topics': ['Technology'],
        'updated_at': updatedAt.toIso8601String(),
      });
    },
  );

  test(
    'given a model when copyWith is called then overrides provided fields',
    () {
      // Act
      final result = model.copyWith(
        id: 'blog-2',
        posterId: 'user-2',
        title: 'New Title',
        content: 'New Content',
        imageUrl: 'https://new-image',
        topics: const [BlogTopic.programming],
        updatedAt: DateTime(2025, 2),
        posterName: 'Bob',
      );

      // Assert
      expect(result.id, 'blog-2');
      expect(result.posterId, 'user-2');
      expect(result.title, 'New Title');
      expect(result.content, 'New Content');
      expect(result.imageUrl, 'https://new-image');
      expect(result.topics, const [BlogTopic.programming]);
      expect(result.updatedAt, DateTime(2025, 2));
      expect(result.posterName, 'Bob');
    },
  );

  test(
    'given a model when copyWith omits values then preserves original fields',
    () {
      // Act
      final result = model.copyWith();

      // Assert
      expect(result.id, model.id);
      expect(result.posterId, model.posterId);
      expect(result.title, model.title);
      expect(result.content, model.content);
      expect(result.imageUrl, model.imageUrl);
      expect(result.topics, model.topics);
      expect(result.updatedAt, model.updatedAt);
      expect(result.posterName, model.posterName);
    },
  );

  test(
    'given a model when toEntity is called then returns a matching Blog',
    () {
      // Act
      final result = model.toEntity();

      // Assert
      expect(result.id, model.id);
      expect(result.posterId, model.posterId);
      expect(result.title, model.title);
      expect(result.content, model.content);
      expect(result.imageUrl, model.imageUrl);
      expect(result.topics, model.topics);
      expect(result.updatedAt, model.updatedAt);
      expect(result.posterName, model.posterName);
    },
  );
}
