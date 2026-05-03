import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id_use_case.dart';

part 'blog_viewer_event.dart';
part 'blog_viewer_state.dart';

/// This bloc is responsible for loading a single blog
/// and providing it to the UI.
class BlogViewerBloc extends Bloc<BlogViewerEvent, BlogViewerState> {
  /// Creates a [BlogViewerBloc].
  BlogViewerBloc({
    required GetBlogByIdUseCase getBlogByIdUseCase,
  }) : _getBlogByIdUseCase = getBlogByIdUseCase,
       super(BlogViewerInitial()) {
    on<LoadBlog>(_loadBlog);
  }

  final GetBlogByIdUseCase _getBlogByIdUseCase;

  Future<void> _loadBlog(
    LoadBlog event,
    Emitter<BlogViewerState> emit,
  ) async {
    emit(BlogViewerLoading());

    final result = await _getBlogByIdUseCase(event.blogId);

    result.fold(
      (failure) => emit(BlogViewerFailure(error: failure.message)),
      (blog) => emit(BlogViewerSuccess(blog: blog)),
    );
  }
}
