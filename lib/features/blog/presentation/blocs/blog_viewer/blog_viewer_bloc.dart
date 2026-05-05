import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id_use_case.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_image_use_case.dart';

part 'blog_viewer_event.dart';
part 'blog_viewer_state.dart';

/// This bloc is responsible for loading a single blog
/// and providing it to the UI.
class BlogViewerBloc extends Bloc<BlogViewerEvent, BlogViewerState> {
  /// Creates a [BlogViewerBloc].
  BlogViewerBloc({
    required GetBlogByIdUseCase getBlogByIdUseCase,
    required GetBlogImageUseCase getBlogImageUseCase,
  }) : _getBlogByIdUseCase = getBlogByIdUseCase,
       _getBlogImageUseCase = getBlogImageUseCase,
       super(BlogViewerInitial()) {
    on<LoadBlog>(_loadBlog);
  }

  final GetBlogByIdUseCase _getBlogByIdUseCase;
  final GetBlogImageUseCase _getBlogImageUseCase;

  Future<void> _loadBlog(
    LoadBlog event,
    Emitter<BlogViewerState> emit,
  ) async {
    emit(BlogViewerLoading());

    final result = await _getBlogByIdUseCase(event.blogId);

    await result.fold<Future<void>>(
      (failure) async {
        emit(BlogViewerFailure(error: failure.message));
      },
      (blog) async {
        final imageResult = await _getBlogImageUseCase(blog);
        final imageFile = imageResult.getOrElse((_) => null);

        emit(
          BlogViewerSuccess(
            blog: blog,
            imageFile: imageFile,
          ),
        );
      },
    );
  }
}
