import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_image_use_case.dart';
import 'package:social_app/features/blog/domain/usecases/observe_blog_by_id_use_case.dart';

part 'blog_viewer_event.dart';
part 'blog_viewer_state.dart';

/// This bloc observes a single blog and provides it to the UI.
class BlogViewerBloc extends Bloc<BlogViewerEvent, BlogViewerState> {
  /// Creates a [BlogViewerBloc].
  BlogViewerBloc({
    required ObserveBlogByIdUseCase observeBlogByIdUseCase,
    required GetBlogImageUseCase getBlogImageUseCase,
  }) : _observeBlogByIdUseCase = observeBlogByIdUseCase,
       _getBlogImageUseCase = getBlogImageUseCase,
       super(BlogViewerInitial()) {
    on<LoadBlog>(_loadBlog);
    on<_BlogReceived>(_onBlogReceived);
  }

  final ObserveBlogByIdUseCase _observeBlogByIdUseCase;
  final GetBlogImageUseCase _getBlogImageUseCase;
  StreamSubscription<Either<Failure, Blog>>? _blogSubscription;

  @override
  Future<void> close() async {
    await _blogSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadBlog(
    LoadBlog event,
    Emitter<BlogViewerState> emit,
  ) async {
    await _blogSubscription?.cancel();
    emit(BlogViewerLoading());

    _blogSubscription = _observeBlogByIdUseCase(event.blogId).listen(
      (result) => add(_BlogReceived(result)),
    );
  }

  Future<void> _onBlogReceived(
    _BlogReceived event,
    Emitter<BlogViewerState> emit,
  ) async {
    await event.result.fold<Future<void>>(
      (failure) async {
        if (state is BlogViewerSuccess) {
          return;
        }

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
