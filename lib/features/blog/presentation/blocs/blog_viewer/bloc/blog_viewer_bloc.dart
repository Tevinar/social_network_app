import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

part 'blog_viewer_event.dart';
part 'blog_viewer_state.dart';

/// This bloc is responsible for loading a single blog
/// and providing it to the UI.
class BlogViewerBloc extends Bloc<BlogViewerEvent, BlogViewerState> {
  /// Creates a [BlogViewerBloc].
  BlogViewerBloc({
    required BlogRepository blogRepository,
  }) : _blogRepository = blogRepository,
       super(BlogViewerInitial()) {
    on<LoadBlog>(_loadBlog);
  }

  final BlogRepository _blogRepository;

  Future<void> _loadBlog(LoadBlog event, Emitter<BlogViewerState> emit) async {
    Blog? cachedBlog;
    for (final blog in event.blogs ?? const <Blog>[]) {
      if (blog.id == event.blogId) {
        cachedBlog = blog;
        break;
      }
    }

    if (cachedBlog != null) {
      emit(BlogViewerSuccess(blog: cachedBlog));
      return;
    }

    // the case is only relevant for deep linking where the blogs page is not
    // loaded before the viewer page
    if (event.blogId != null) {
      emit(BlogViewerLoading());
      final result = await _blogRepository.getBlogById(event.blogId!);

      result.fold(
        (failure) => emit(BlogViewerFailure(error: failure.message)),
        (blog) => emit(BlogViewerSuccess(blog: blog)),
      );
      return;
    }

    emit(BlogViewerFailure(error: 'Blog not found'));
  }
}
