import 'dart:async';

import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/entities/blog_change.dart';
import 'package:bloc_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:bloc_app/features/blog/domain/usecases/get_blogs_count.dart';
import 'package:bloc_app/features/blog/domain/usecases/get_blogs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'blogs_event.dart';
part 'blogs_state.dart';

/// BLoC responsible for displaying a paginated list of blogs.
///
/// This bloc combines:
/// - pagination via use cases (`GetBlogsPage`, `GetBlogsCount`)
/// - real-time blog updates via a passive repository stream
/// - infinite scrolling driven by a `ScrollController`
///
/// Blog changes (insert/update/delete) are received through a stream and
/// converted into events to ensure all state mutations flow through the
/// BLoC event system.

/// Manages the blog feed state, including pagination, loading states,
/// and real-time updates to already loaded blogs.
class BlogsBloc extends Bloc<BlogsEvent, BlogsState> {
  final GetBlogsPage _getBlogsPage;
  final GetBlogsCount _getBlogsCount;
  final BlogRepository _repository;

  // Listens to scroll position to trigger pagination when nearing the bottom
  final ScrollController _scrollController = ScrollController();
  // Subscription to passive blog change stream (insert/update/delete)
  late final StreamSubscription<Either<Failure, BlogChange>> _blogChangeSub;

  /// Creates the BlogsBloc and immediately:
  /// - starts listening to scroll events for pagination
  /// - subscribes to real-time blog changes
  /// - triggers the initial page load
  BlogsBloc({
    required GetBlogsPage getBlogsPage,
    required GetBlogsCount getBlogsCount,
    required BlogRepository repository,
  }) : _getBlogsPage = getBlogsPage,
       _getBlogsCount = getBlogsCount,
       _repository = repository,
       super(const BlogsLoading(blogs: [], pageNumber: 1)) {
    on<LoadBlogsNextPage>(_onLoadBlogsNextPage);
    on<BlogChangeReceived>(onBlogChangeReceived);

    _addListenerToScrollController();
    _addListenerToSubscription();

    add(LoadBlogsNextPage());
  }

  @override
  Future<void> close() {
    _blogChangeSub.cancel();
    _scrollController.dispose();
    return super.close();
  }

  // Triggers pagination when the user scrolls close to the bottom of the list.
  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(LoadBlogsNextPage());
      }
    });
  }

  /// Subscribes to passive blog change events from the repository.
  ///
  /// Stream emissions are converted into `BlogChangeReceived` events to
  /// ensure that all state updates go through the BLoC event pipeline
  /// (streams must never emit states directly).
  void _addListenerToSubscription() {
    _blogChangeSub = _repository.watchBlogChanges().listen((
      Either<Failure, BlogChange> event,
    ) {
      add(BlogChangeReceived(event));
    });
  }

  /// Applies real-time blog changes (insert/update/delete) to the current state.
  ///
  /// These changes may affect blogs that were already loaded via pagination.
  /// This handler does not trigger refetching or pagination.
  void onBlogChangeReceived(
    BlogChangeReceived event,
    Emitter<BlogsState> emit,
  ) {
    event.blogChange.fold(
      (failure) {
        emit(
          BlogsFailure(
            error: failure.message,
            blogs: state.blogs,
            pageNumber: state.pageNumber,
            totalBlogsInDatabase: state.totalBlogsInDatabase,
          ),
        );
      },
      (blogChange) {
        if (blogChange is BlogInserted) {
          emit(
            state.copyWith(
              blogs: [blogChange.blog, ...state.blogs],
              totalBlogsInDatabase: (state.totalBlogsInDatabase ?? 0) + 1,
            ),
          );
        }

        if (blogChange is BlogUpdated) {
          emit(
            state.copyWith(
              blogs: state.blogs
                  .map(
                    (blog) =>
                        blog.id == blogChange.blog.id ? blogChange.blog : blog,
                  )
                  .toList(),
            ),
          );
        }

        if (blogChange is BlogDeleted) {
          emit(
            state.copyWith(
              blogs: state.blogs
                  .where((blog) => blog.id != blogChange.blogId)
                  .toList(),
              totalBlogsInDatabase: (state.totalBlogsInDatabase ?? 1) - 1,
            ),
          );
        }
      },
    );
  }

  /// Loads the next page of blogs if available.
  ///
  /// Pagination is skipped if:
  /// - the total number of blogs is already loaded
  /// - a loading operation is already in progress
  Future<void> _onLoadBlogsNextPage(
    LoadBlogsNextPage event,
    Emitter<BlogsState> emit,
  ) async {
    if (state.totalBlogsInDatabase == null) {
      await _initializeBlogsCount(emit);
    }

    // If we don't have more blogs to load, do nothing
    if (state.blogs.length == state.totalBlogsInDatabase) {
      return;
    }
    // Avoid emitting loading state if we already have blogs loading
    // This is not triggered on the initial load
    if (state is BlogsLoading && state.blogs.isNotEmpty) {
      return;
    }

    emit(
      BlogsLoading(
        blogs: state.blogs,
        pageNumber: state.pageNumber,
        totalBlogsInDatabase: state.totalBlogsInDatabase,
      ),
    );
    final Either<Failure, List<Blog>> result = await _getBlogsPage(
      state.pageNumber,
    );
    result.fold(
      (error) {
        emit(
          BlogsFailure(
            error: error.message,
            blogs: state.blogs,
            pageNumber: state.pageNumber,
            totalBlogsInDatabase: state.totalBlogsInDatabase,
          ),
        );
      },
      (blogsNextPage) {
        List<Blog> newBlogs = [...state.blogs, ...blogsNextPage];
        emit(
          BlogsSuccess(
            blogs: newBlogs,
            pageNumber: state.pageNumber + 1,
            totalBlogsInDatabase: state.totalBlogsInDatabase,
          ),
        );
      },
    );
  }

  ScrollController get scrollController => _scrollController;

  /// Lazily initializes the total number of blogs in the database.
  ///
  /// This value is used to determine when pagination has reached the end.
  Future<void> _initializeBlogsCount(Emitter<BlogsState> emit) async {
    final Either<Failure, int> result = await _getBlogsCount(NoParams());
    result.fold(
      (error) {
        emit(
          BlogsFailure(
            error: error.message,
            blogs: state.blogs,
            pageNumber: state.pageNumber,
          ),
        );
      },
      (count) {
        emit(
          BlogsLoading(
            blogs: state.blogs,
            pageNumber: state.pageNumber,
            totalBlogsInDatabase: count,
          ),
        );
      },
    );
  }
}
