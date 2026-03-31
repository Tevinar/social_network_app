import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/create_blog.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_editor/blog_editor_bloc.dart';

class MockCreateBlog extends Mock implements CreateBlog {}

class FakeCreateBlogParams extends Fake implements CreateBlogParams {}

void main() {
  late MockCreateBlog createBlog;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
  );

  setUpAll(() {
    registerFallbackValue(
      CreateBlogParams(
        posterId: '',
        title: '',
        content: '',
        image: File('/tmp/image.png'),
        topics: const [],
      ),
    );
    registerFallbackValue(FakeCreateBlogParams());
  });

  setUp(() {
    createBlog = MockCreateBlog();
  });

  test(
    'given the bloc is created when reading state then state is BlogInitial',
    () {
      // Act
      final bloc = BlogEditorBloc(uploadBlog: createBlog);
      addTearDown(bloc.close);

      // Assert
      expect(bloc.state, isA<BlogInitial>());
    },
  );

  blocTest<BlogEditorBloc, BlogEditorState>(
    'given create blog succeeds when AddBlog is added then emits '
    'BlogLoading and BlogUploadSuccess',
    build: () {
      when(() => createBlog(any())).thenAnswer((_) async => right(blog));
      return BlogEditorBloc(uploadBlog: createBlog);
    },
    act: (bloc) => bloc.add(
      AddBlog(
        posterId: 'user-1',
        title: 'Title',
        content: 'Content',
        image: File('/tmp/image.png'),
        topics: const ['Tech'],
      ),
    ),
    expect: () => [isA<BlogLoading>(), isA<BlogUploadSuccess>()],
    verify: (_) {
      verify(
        () => createBlog(
          any(
            that: isA<CreateBlogParams>()
                .having((p) => p.posterId, 'posterId', 'user-1')
                .having((p) => p.title, 'title', 'Title')
                .having((p) => p.content, 'content', 'Content')
                .having((p) => p.topics, 'topics', const ['Tech']),
          ),
        ),
      ).called(1);
    },
  );

  blocTest<BlogEditorBloc, BlogEditorState>(
    'given create blog fails when AddBlog is added then emits BlogLoading '
    'and BlogFailure',
    build: () {
      when(() => createBlog(any())).thenAnswer(
        (_) async => left(const ValidationFailure('Invalid blog')),
      );
      return BlogEditorBloc(uploadBlog: createBlog);
    },
    act: (bloc) => bloc.add(
      AddBlog(
        posterId: 'user-1',
        title: 'Title',
        content: 'Content',
        image: File('/tmp/image.png'),
        topics: const ['Tech'],
      ),
    ),
    expect: () => [
      isA<BlogLoading>(),
      isA<BlogFailure>().having(
        (state) => state.error,
        'error',
        'Invalid blog',
      ),
    ],
  );
}
