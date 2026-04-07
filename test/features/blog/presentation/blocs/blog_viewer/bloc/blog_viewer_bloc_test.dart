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
    'given fetching by id succeeds when LoadBlog is added then it emits '
    'BlogViewerSuccess',
    build: () {
      when(() => getBlogById(blog.id)).thenAnswer(
        (_) async => right<Failure, Blog>(blog),
      );
      return BlogViewerBloc(getBlogById: getBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerSuccess>().having((state) => state.blog, 'blog', blog),
    ],
    verify: (_) {
      verify(() => getBlogById(blog.id)).called(1);
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given fetching by id fails when LoadBlog is added then it emits '
    'failure',
    build: () {
      when(() => getBlogById(blog.id)).thenAnswer(
        (_) async => left(const ValidationFailure('Blog fetch failed')),
      );
      return BlogViewerBloc(getBlogById: getBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerFailure>().having(
        (state) => state.error,
        'error',
        'Blog fetch failed',
      ),
    ],
    verify: (_) {
      verify(() => getBlogById(blog.id)).called(1);
    },
  );
}
