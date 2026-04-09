import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_by_id.dart';

part 'blog_viewer_event.dart';
part 'blog_viewer_state.dart';

/// This bloc is responsible for loading a single blog
/// and providing it to the UI.
class BlogViewerBloc extends Bloc<BlogViewerEvent, BlogViewerState> {
  /// Creates a [BlogViewerBloc].
  BlogViewerBloc({
    required WatchBlogById watchBlogById,
  }) : _watchBlogById = watchBlogById,
       super(BlogViewerInitial()) {
    on<LoadBlog>(_loadBlog);
  }

  final WatchBlogById _watchBlogById;

  Future<void> _loadBlog(LoadBlog event, Emitter<BlogViewerState> emit) async {
    emit(BlogViewerLoading());

    await emit.forEach(
      _watchBlogById(event.blogId),
      onData: (result) => result.fold(
        (failure) => BlogViewerFailure(error: failure.message),
        (snapshot) => BlogViewerSuccess(
          blog: snapshot.blog,
          isFromCache: snapshot.source == BlogSource.cache,
          refreshError: snapshot.refreshFailure?.message,
        ),
      ),
    );
  }
}
