import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_viewer/bloc/blog_viewer_bloc.dart';

class MockGetBlogById extends Mock implements GetBlogById {}

void main() {
  late MockGetBlogById getBlogById;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUp(() {
    getBlogById = MockGetBlogById();
  });

  test(
    'given the bloc is created when reading state then state is '
    'BlogViewerInitial',
    () {
      final bloc = BlogViewerBloc(getBlogById: getBlogById);
      addTearDown(bloc.close);

      expect(bloc.state, isA<BlogViewerInitial>());
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given a matching cached blog when LoadBlog is added then it emits '
    'BlogViewerSuccess without fetching',
    build: () => BlogViewerBloc(getBlogById: getBlogById),
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id, blogs: [blog])),
    expect: () => [
      isA<BlogViewerSuccess>().having((state) => state.blog, 'blog', blog),
    ],
    verify: (_) {
      verifyNever(() => getBlogById(any()));
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given no matching cached blog when LoadBlog is added then it emits '
    'loading and fetched success',
    build: () {
      when(() => getBlogById(blog.id)).thenAnswer(
        (_) async => right<Failure, Blog>(blog),
      );
      return BlogViewerBloc(getBlogById: getBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: 'blog-1', blogs: [])),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerSuccess>().having((state) => state.blog, 'blog', blog),
    ],
    verify: (_) {
      verify(() => getBlogById(blog.id)).called(1);
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given fetching by id fails when LoadBlog is added then it emits '
    'loading and failure',
    build: () {
      when(() => getBlogById(blog.id)).thenAnswer(
        (_) async => left(const ValidationFailure('Blog fetch failed')),
      );
      return BlogViewerBloc(getBlogById: getBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: 'blog-1', blogs: [])),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerFailure>().having(
        (state) => state.error,
        'error',
        'Blog fetch failed',
      ),
    ],
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given no blog id when LoadBlog is added then it emits BlogViewerFailure',
    build: () => BlogViewerBloc(getBlogById: getBlogById),
    act: (bloc) => bloc.add(LoadBlog(blogs: const [])),
    expect: () => [
      isA<BlogViewerFailure>().having(
        (state) => state.error,
        'error',
        'Blog not found',
      ),
    ],
  );
}
