import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/blog/data/data_sources/blog_local_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

void main() {
  late AppDatabase database;
  late BlogLocalDataSourceDriftImpl dataSource;

  BlogModel buildBlog({
    required String id,
    required DateTime updatedAt,
    String title = 'Title',
    List<BlogTopic> topics = const [BlogTopic.technology],
  }) {
    return BlogModel(
      id: id,
      posterId: 'user-$id',
      title: title,
      content: 'Content for $id',
      imageUrl: 'https://image.test/$id.png',
      topics: topics,
      updatedAt: updatedAt,
      posterName: 'Poster $id',
    );
  }

  setUp(() {
    database = AppDatabase.test(NativeDatabase.memory());
    dataSource = BlogLocalDataSourceDriftImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'given blogs are cached when getBlogById is called then it returns the '
    'stored blog with topics and poster name',
    () async {
      final blog = buildBlog(
        id: 'blog-1',
        updatedAt: DateTime(2025),
        topics: const [BlogTopic.business, BlogTopic.programming],
      );

      await dataSource.upsertBlogs([blog]);

      final result = await dataSource.getBlogById(blog.id);

      expect(result, isNotNull);
      expect(result!.id, blog.id);
      expect(result.posterName, blog.posterName);
      expect(result.topics, blog.topics);
    },
  );

  test(
    'given a blog with the same id already exists when upsertBlogs is called '
    'then it updates the stored row instead of duplicating it',
    () async {
      final initialBlog = buildBlog(
        id: 'blog-2',
        updatedAt: DateTime(2025),
        title: 'Old title',
      );
      final updatedBlog = buildBlog(
        id: 'blog-2',
        updatedAt: DateTime(2025, 1, 2),
        title: 'New title',
        topics: const [BlogTopic.entertainment],
      );

      await dataSource.upsertBlogs([initialBlog]);
      await dataSource.upsertBlogs([updatedBlog]);

      final storedBlog = await dataSource.getBlogById(updatedBlog.id);
      final firstPage = await dataSource.getBlogsPage(1);

      expect(storedBlog, isNotNull);
      expect(storedBlog!.title, 'New title');
      expect(storedBlog.topics, const [BlogTopic.entertainment]);
      expect(firstPage, hasLength(1));
    },
  );

  test(
    'given more than one page of blogs when getBlogsPage is called then it '
    'returns them ordered by updatedAt descending and paginated',
    () async {
      final blogs = List.generate(
        21,
        (index) => buildBlog(
          id: 'blog-$index',
          updatedAt: DateTime(2025).add(Duration(days: index)),
          title: 'Blog $index',
        ),
      );

      await dataSource.upsertBlogs(blogs);

      final firstPage = await dataSource.getBlogsPage(1);
      final secondPage = await dataSource.getBlogsPage(2);

      expect(firstPage, hasLength(20));
      expect(secondPage, hasLength(1));
      expect(firstPage.first.title, 'Blog 20');
      expect(firstPage.last.title, 'Blog 1');
      expect(secondPage.single.title, 'Blog 0');
    },
  );

  test(
    'given a cached blog when deleteBlog is called then the blog is removed',
    () async {
      final blog = buildBlog(
        id: 'blog-3',
        updatedAt: DateTime(2025),
      );

      await dataSource.upsertBlogs([blog]);
      await dataSource.deleteBlog(blog.id);

      final result = await dataSource.getBlogById(blog.id);

      expect(result, isNull);
    },
  );

  test(
    'given cached blogs when clearAll is called then the cache becomes empty',
    () async {
      await dataSource.upsertBlogs([
        buildBlog(id: 'blog-4', updatedAt: DateTime(2025)),
        buildBlog(id: 'blog-5', updatedAt: DateTime(2025, 1, 2)),
      ]);

      await dataSource.clearAll();

      final firstPage = await dataSource.getBlogsPage(1);

      expect(firstPage, isEmpty);
    },
  );
}
