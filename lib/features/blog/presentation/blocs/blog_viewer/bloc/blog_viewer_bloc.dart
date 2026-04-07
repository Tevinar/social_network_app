import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id.dart';

part 'blog_viewer_event.dart';
part 'blog_viewer_state.dart';

/// This bloc is responsible for loading a single blog
/// and providing it to the UI.
class BlogViewerBloc extends Bloc<BlogViewerEvent, BlogViewerState> {
  /// Creates a [BlogViewerBloc].
  BlogViewerBloc({
    required GetBlogById getBlogById,
  }) : _getBlogById = getBlogById,
       super(BlogViewerInitial()) {
    on<LoadBlog>(_loadBlog);
  }

  final GetBlogById _getBlogById;

  Future<void> _loadBlog(LoadBlog event, Emitter<BlogViewerState> emit) async {
    final result = await _getBlogById(event.blogId);

    result.fold(
      (failure) => emit(BlogViewerFailure(error: failure.message)),
      (blog) => emit(BlogViewerSuccess(blog: blog)),
    );
    return;
  }
}
