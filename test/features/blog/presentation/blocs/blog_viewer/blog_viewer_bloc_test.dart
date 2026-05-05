import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id_use_case.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_image_use_case.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_viewer/blog_viewer_bloc.dart';

class MockGetBlogByIdUseCase extends Mock implements GetBlogByIdUseCase {}

class MockGetBlogImageUseCase extends Mock implements GetBlogImageUseCase {}

void main() {
  late MockGetBlogByIdUseCase getBlogByIdUseCase;
  late MockGetBlogImageUseCase getBlogImageUseCase;
  late BlogViewerBloc bloc;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Blog title',
    content: 'Blog content',
    imageUrl: 'https://example.com/blog-1.png',
    topics: [BlogTopic.technology],
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 2),
    posterName: 'Test User',
  );

  final imageFile = File('${Directory.systemTemp.path}/blog-image-test.img');

  setUp(() {
    getBlogByIdUseCase = MockGetBlogByIdUseCase();
    getBlogImageUseCase = MockGetBlogImageUseCase();
    bloc = BlogViewerBloc(
      getBlogByIdUseCase: getBlogByIdUseCase,
      getBlogImageUseCase: getBlogImageUseCase,
    );
  });

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given blog and image loads succeed when LoadBlog is added then loading and success with image file are emitted',
    build: () {
      when(
        () => getBlogByIdUseCase(blog.id),
      ).thenAnswer((_) async => right(blog));
      when(
        () => getBlogImageUseCase(blog),
      ).thenAnswer((_) async => right(imageFile));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerSuccess>()
          .having((state) => state.blog, 'blog', blog)
          .having((state) => state.imageFile, 'image file', imageFile),
    ],
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given blog load succeeds and image load fails when LoadBlog is added then success with a null image file is emitted',
    build: () {
      when(
        () => getBlogByIdUseCase(blog.id),
      ).thenAnswer((_) async => right(blog));
      when(
        () => getBlogImageUseCase(blog),
      ).thenAnswer((_) async => left(const NetworkFailure()));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerSuccess>()
          .having((state) => state.blog, 'blog', blog)
          .having((state) => state.imageFile, 'image file', isNull),
    ],
  );
}
