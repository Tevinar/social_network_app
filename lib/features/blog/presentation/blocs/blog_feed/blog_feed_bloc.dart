import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/events/blog_feed_event.dart';
import 'package:social_app/features/blog/domain/read_models/blog_feed_slice.dart';
import 'package:social_app/features/blog/domain/usecases/watch_feed_events_use_case.dart';
import 'package:social_app/features/blog/domain/usecases/watch_feed_slice_use_case.dart';

part 'blog_feed_bloc_event.dart';
part 'blog_feed_state.dart';

/// Bloc responsible for loading, paginating, and refreshing the blog feed.
class BlogFeedBloc extends Bloc<BlogFeedBlocEvent, BlogFeedState> {
  /// Creates a [BlogFeedBloc].
  BlogFeedBloc({
    required WatchFeedSliceUseCase watchFeedSliceUseCase,
    required WatchFeedEventsUseCase watchFeedEventsUseCase,
  }) : _watchFeedSliceUseCase = watchFeedSliceUseCase,
       _watchFeedEventsUseCase = watchFeedEventsUseCase,
       super(
         const BlogFeedLoading(
           blogs: [],
           nextCursor: null,
           hasNewContentAvailable: false,
           isLoadingMore: false,
           isFromCache: false,
           refreshError: null,
         ),
       ) {
    on<LoadInitialFeed>(_onLoadInitialFeed);
    on<LoadMoreFeed>(_onLoadMoreFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<_FeedSliceReceived>(_onFeedSliceReceived);
    on<_FeedEventReceived>(_onFeedEventReceived);

    _scrollController.addListener(_onScroll);
    _subscribeToFeedEvents();

    add(const LoadInitialFeed());
  }

  final WatchFeedSliceUseCase _watchFeedSliceUseCase;
  final WatchFeedEventsUseCase _watchFeedEventsUseCase;

  final ScrollController _scrollController = ScrollController();

  StreamSubscription<Either<Failure, BlogFeedEvent>>? _feedEventsSubscription;
  StreamSubscription<Either<Failure, BlogFeedSlice>>? _feedSliceSubscription;

  // Prevent repeated bottom-of-list scroll events from starting the same
  // "load more" request multiple times before the current one completes.
  bool _isLoadingMoreRequestInFlight = false;

  /// Scroll controller used by the feed list view.
  ScrollController get scrollController => _scrollController;

  @override
  Future<void> close() async {
    try {
      await _feedEventsSubscription?.cancel();
      await _feedSliceSubscription?.cancel();
    } finally {
      _scrollController.dispose();
      await super.close();
    }
  }

  /// Smoothly scrolls the feed back to the top.
  Future<void> scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      add(const LoadMoreFeed());
    }
  }

  void _subscribeToFeedEvents() {
    _feedEventsSubscription = _watchFeedEventsUseCase().listen(
      (result) => add(_FeedEventReceived(result)),
    );
  }

  Future<void> _onLoadInitialFeed(
    LoadInitialFeed event,
    Emitter<BlogFeedState> emit,
  ) async {
    await _feedSliceSubscription?.cancel();

    emit(
      BlogFeedLoading(
        blogs: state.blogs,
        nextCursor: state.nextCursor,
        hasNewContentAvailable: state.hasNewContentAvailable,
        isLoadingMore: false,
        isFromCache: false,
        refreshError: null,
      ),
    );

    _feedSliceSubscription = _watchFeedSliceUseCase(null).listen(
      (result) => add(
        _FeedSliceReceived(
          result: result,
          isFirstSlice: true,
        ),
      ),
    );
  }

  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<BlogFeedState> emit,
  ) async {
    add(const LoadInitialFeed());
  }

  Future<void> _onLoadMoreFeed(
    LoadMoreFeed event,
    Emitter<BlogFeedState> emit,
  ) async {
    if (_isLoadingMoreRequestInFlight) {
      return;
    }

    final cursor = state.nextCursor;
    if (cursor == null) {
      return;
    }

    _isLoadingMoreRequestInFlight = true;

    emit(
      state.copyWith(
        isLoadingMore: true,
        refreshError: null,
      ),
    );

    await _watchFeedSliceUseCase(cursor).forEach((result) {
      add(
        _FeedSliceReceived(
          result: result,
          isFirstSlice: false,
        ),
      );
    });

    _isLoadingMoreRequestInFlight = false;
  }

  void _onFeedSliceReceived(
    _FeedSliceReceived event,
    Emitter<BlogFeedState> emit,
  ) {
    event.result.fold(
      (failure) {
        if (state.blogs.isEmpty) {
          emit(
            BlogFeedFailure(
              error: failure.message,
              blogs: state.blogs,
              nextCursor: state.nextCursor,
              hasNewContentAvailable: state.hasNewContentAvailable,
              isLoadingMore: false,
              isFromCache: false,
              refreshError: null,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            isLoadingMore: false,
            refreshError: failure.message,
          ),
        );
      },
      (snapshot) {
        final nextBlogs = event.isFirstSlice
            ? snapshot.blogs
            : [...state.blogs, ...snapshot.blogs];

        emit(
          BlogFeedSuccess(
            blogs: nextBlogs,
            nextCursor: snapshot.nextCursor,
            hasNewContentAvailable: false,
            isLoadingMore: false,
            isFromCache: snapshot.source == BlogFeedSource.cache,
            refreshError: snapshot.refreshFailure?.message,
          ),
        );
      },
    );
  }

  void _onFeedEventReceived(
    _FeedEventReceived event,
    Emitter<BlogFeedState> emit,
  ) {
    event.result.fold(
      (failure) {
        emit(
          state.copyWith(
            refreshError: failure.message,
          ),
        );
      },
      (feedEvent) {
        switch (feedEvent.type) {
          case BlogFeedEventType.newBlogAvailable:
            emit(
              state.copyWith(
                hasNewContentAvailable: true,
              ),
            );
        }
      },
    );
  }
}
