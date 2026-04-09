import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/constants/blog_paging.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_count.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_page.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_changes.dart';

part 'blogs_event.dart';
part 'blogs_state.dart';

/// BLoC responsible for displaying a paginated list of blogs.
///
/// This bloc combines:
/// - pagination via use cases (`WatchBlogsPage`, `GetBlogsCount`)
/// - real-time blog updates via a stream use case
/// - infinite scrolling driven by a `ScrollController`
/// - cache-first page loading where a single page may emit more than once
///
/// Blog changes (insert/update/delete) are received through a stream and
/// converted into events to ensure all state mutations flow through the
/// BLoC event system.
///
/// A page loaded through `WatchBlogsPage` can emit:
/// - cached data first
/// - fresh remote data later
/// - cached data again with a refresh failure
///
/// Because of that, the bloc stores pages internally in `_pages` and replaces
/// a page's content when a newer snapshot arrives instead of blindly appending
/// blogs to the existing flat list.

/// Manages the blog feed state, including pagination, loading states,
/// and real-time updates to already loaded blogs.
class BlogsBloc extends Bloc<BlogsEvent, BlogsState> {
  /// Creates the BlogsBloc and immediately:
  /// - starts listening to scroll events for pagination
  /// - subscribes to real-time blog changes
  /// - triggers the initial page load
  BlogsBloc({
    required WatchBlogsPage watchBlogsPage,
    required GetBlogsCount getBlogsCount,
    required WatchBlogChanges watchBlogChanges,
  }) : _watchBlogsPage = watchBlogsPage,
       _getBlogsCount = getBlogsCount,
       _watchBlogChanges = watchBlogChanges,
       super(const BlogsLoading(blogs: [], pageNumber: 1)) {
    on<LoadBlogsNextPage>(_onLoadBlogsNextPage);
    on<BlogChangeReceived>(_onBlogChangeReceived);
    on<RefreshBlogsView>(_onRefreshBlogsView);
    on<_BlogsPageSnapshotReceived>(_onBlogsPageSnapshotReceived);

    _addListenerToScrollController();
    _addListenerToSubscription();

    add(LoadBlogsNextPage());
  }

  /// Stream use case used to observe one page at a time with cache-first
  /// semantics.
  final WatchBlogsPage _watchBlogsPage;

  /// One-shot use case used to retrieve the total number of blogs.
  final GetBlogsCount _getBlogsCount;

  /// Passive stream used to receive realtime insert/update/delete events.
  final WatchBlogChanges _watchBlogChanges;

  /// Scroll controller exposed to the page for infinite scroll behavior.
  final ScrollController _scrollController = ScrollController();

  /// Subscription to the global realtime blog-change stream.
  late final StreamSubscription<Either<Failure, BlogChange>> _blogChangeSub;

  /// Loaded pages keyed by page number.
  ///
  /// This is the bloc's source of truth for paginated data. It lets the bloc
  /// replace a page when a fresher snapshot arrives without duplicating items
  /// already rendered from a cached emission.
  final Map<int, List<Blog>> _pages = {};

  /// Active page subscriptions keyed by page number.
  ///
  /// Each page is listened to independently because `WatchBlogsPage(page)` is a
  /// stream that may emit multiple snapshots for the same page.
  final Map<int, StreamSubscription<Either<Failure, BlogsPageSnapshot>>>
  _pageSubs = {};

  @override
  /// Cancels realtime and page-level subscriptions before disposing the
  /// controller and closing the bloc.
  Future<void> close() async {
    try {
      await Future.wait([
        _blogChangeSub.cancel(),
        ..._pageSubs.values.map((subscription) => subscription.cancel()),
      ]);
    } finally {
      try {
        _scrollController.dispose();
      } finally {
        await super.close();
      }
    }
  }

  /// Re-emits the current state to force a rebuild without changing data.
  void _onRefreshBlogsView(RefreshBlogsView event, Emitter<BlogsState> emit) {
    emit(state.copyWith());
  }

  /// Triggers pagination when the user scrolls close to the bottom of the
  /// current list.
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
    _blogChangeSub = _watchBlogChanges(const NoParams()).listen((
      event,
    ) {
      add(BlogChangeReceived(event));
    });
  }

  /// Applies real-time blog changes (insert/update/delete) to the current state.
  ///
  /// These changes may affect blogs that were already loaded via pagination.
  /// This handler does not trigger refetching or pagination.
  ///
  /// After applying the change to the flat list shown in the state, `_pages`
  /// is rebuilt from that updated list so future cache/remote page snapshots
  /// remain aligned with the currently visible feed.
  void _onBlogChangeReceived(
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
        final updatedBlogs = switch (blogChange) {
          BlogInserted(:final blog) => [blog, ...state.blogs],
          BlogUpdated(:final blog) =>
            state.blogs
                .map(
                  (loadedBlog) => loadedBlog.id == blog.id ? blog : loadedBlog,
                )
                .toList(),
          BlogDeleted(:final blogId) =>
            state.blogs.where((blog) => blog.id != blogId).toList(),
        };
        final nextTotalBlogsInDatabase = switch (blogChange) {
          BlogInserted() => (state.totalBlogsInDatabase ?? 0) + 1,
          BlogDeleted() => (state.totalBlogsInDatabase ?? 1) - 1,
          BlogUpdated() => state.totalBlogsInDatabase,
        };

        _syncPagesFromBlogs(updatedBlogs);

        emit(
          state.copyWith(
            blogs: updatedBlogs,
            totalBlogsInDatabase: nextTotalBlogsInDatabase,
          ),
        );
      },
    );
  }

  /// Rebuilds the internal page map from a flat list of blogs.
  ///
  /// This is used after realtime insert/update/delete events, which operate on
  /// the list currently shown to the user rather than on a single page.
  void _syncPagesFromBlogs(List<Blog> blogs) {
    _pages
      ..clear()
      ..addAll(_chunkBlogs(blogs));
  }

  /// Splits a flat list of blogs into fixed-size pages using `blogPageSize`.
  Map<int, List<Blog>> _chunkBlogs(List<Blog> blogs) {
    final pages = <int, List<Blog>>{};

    for (var start = 0; start < blogs.length; start += blogPageSize) {
      final pageNumber = (start ~/ blogPageSize) + 1;
      final end = start + blogPageSize > blogs.length
          ? blogs.length
          : start + blogPageSize;
      pages[pageNumber] = blogs.sublist(start, end);
    }

    return pages;
  }

  /// Loads the next page of blogs if available.
  ///
  /// Pagination is skipped if:
  /// - the total number of blogs is already loaded
  /// - a stream for the requested page is already active
  ///
  /// The requested page is listened to as a stream rather than awaited once,
  /// because the repository may emit cached data first and then fresh remote
  /// data for the same page.
  Future<void> _onLoadBlogsNextPage(
    LoadBlogsNextPage event,
    Emitter<BlogsState> emit,
  ) async {
    if (state.totalBlogsInDatabase == null) {
      await _initializeBlogsCount(emit);
    }

    final pageToLoad = state.pageNumber;
    final totalBlogsInDatabase = state.totalBlogsInDatabase;

    if (_pageSubs.containsKey(pageToLoad)) {
      return;
    }

    if (totalBlogsInDatabase != null &&
        totalBlogsInDatabase != 0 &&
        state.blogs.length >= totalBlogsInDatabase) {
      return;
    }

    emit(
      BlogsLoading(
        blogs: state.blogs,
        pageNumber: state.pageNumber,
        totalBlogsInDatabase: state.totalBlogsInDatabase,
      ),
    );

    _pageSubs[pageToLoad] = _watchBlogsPage(pageToLoad).listen(
      (result) {
        add(_BlogsPageSnapshotReceived(pageToLoad, result));
      },
      onDone: () {
        _pageSubs.remove(pageToLoad);
      },
    );
  }

  /// The scroll controller.
  ScrollController get scrollController => _scrollController;

  /// The scroll to top.
  Future<void> scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Lazily initializes the total number of blogs in the database.
  ///
  /// This value is used to determine when pagination has reached the end.
  Future<void> _initializeBlogsCount(Emitter<BlogsState> emit) async {
    final result = await _getBlogsCount(const NoParams());
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

  /// Applies a cache-first page snapshot emitted by `WatchBlogsPage`.
  ///
  /// A successful snapshot replaces the page stored under `event.pageNumber`,
  /// then all loaded pages are flattened in order to rebuild the list exposed
  /// by the public state.
  ///
  /// If `refreshFailure` is present, the bloc keeps the last usable blogs but
  /// exposes the refresh error through a `BlogsFailure` state.
  void _onBlogsPageSnapshotReceived(
    _BlogsPageSnapshotReceived event,
    Emitter<BlogsState> emit,
  ) {
    event.result.fold(
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
      (snapshot) {
        _pages[event.pageNumber] = snapshot.blogs;
        final flattenedBlogs = _flattenPages();
        final nextPageNumber = _nextPageNumber();

        if (snapshot.refreshFailure != null) {
          emit(
            BlogsFailure(
              error: snapshot.refreshFailure!.message,
              blogs: flattenedBlogs,
              pageNumber: nextPageNumber,
              totalBlogsInDatabase: state.totalBlogsInDatabase,
            ),
          );
          return;
        }

        emit(
          BlogsSuccess(
            blogs: flattenedBlogs,
            pageNumber: nextPageNumber,
            totalBlogsInDatabase: state.totalBlogsInDatabase,
          ),
        );
      },
    );
  }

  /// Flattens all loaded pages into a single ordered list for UI consumption.
  List<Blog> _flattenPages() {
    final orderedPages = _pages.keys.toList()..sort();
    return orderedPages.expand((pageNumber) => _pages[pageNumber]!).toList();
  }

  /// Returns the next page number that should be requested.
  ///
  /// This is derived from the highest loaded page, not from the current state
  /// object, so repeated cache/remote emissions for the same page do not
  /// accidentally advance pagination more than once.
  int _nextPageNumber() {
    if (_pages.isEmpty) {
      return 1;
    }

    return (_pages.keys.reduce((left, right) => left > right ? left : right)) +
        1;
  }
}
