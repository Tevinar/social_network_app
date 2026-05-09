import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/read_models/blog_list_slice.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_list_slice_use_case.dart';
import 'package:social_app/features/blog/domain/usecases/observe_initial_blog_list_slice_use_case.dart';

part 'blog_list_event.dart';
part 'blog_list_state.dart';

/// Bloc responsible for loading, paginating, and refreshing the blog list.
class BlogListBloc extends Bloc<BlogListEvent, BlogListState> {
  /// Creates a [BlogListBloc].
  BlogListBloc({
    required ObserveInitialBlogListSliceUseCase
    observeInitialBlogListSliceUseCase,
    required GetBlogListSliceUseCase getBlogListSliceUseCase,
  }) : _observeInitialBlogListSliceUseCase = observeInitialBlogListSliceUseCase,
       _getBlogListSliceUseCase = getBlogListSliceUseCase,
       super(
         const BlogListLoading(
           blogs: [],
           nextCursor: null,
           isFromCache: false,
           refreshError: null,
         ),
       ) {
    _addListenerToScrollController();
    on<LoadInitialList>(_onLoadInitialList);
    on<LoadMoreList>(_onLoadMoreList);
    on<RefreshList>(_onRefreshList);
    on<PrependCreatedBlog>(_onPrependCreatedBlog);
    on<_InitialListSliceReceived>(_onInitialListSliceReceived);

    add(const LoadInitialList());
  }

  static const int _pageSize = 20;

  final ObserveInitialBlogListSliceUseCase _observeInitialBlogListSliceUseCase;
  final GetBlogListSliceUseCase _getBlogListSliceUseCase;

  final ScrollController _scrollController = ScrollController();

  StreamSubscription<Either<Failure, BlogListSlice>>? _listSliceSubscription;

  /// Scroll controller used by the list view.
  ScrollController get scrollController => _scrollController;

  @override
  Future<void> close() async {
    try {
      await _listSliceSubscription?.cancel();
    } finally {
      _scrollController.dispose();
      await super.close();
    }
  }

  /// Smoothly scrolls the list back to the top.
  Future<void> scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _addListenerToScrollController() {
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      add(const LoadMoreList());
    }
  }

  Future<void> _onLoadInitialList(
    LoadInitialList event,
    Emitter<BlogListState> emit,
  ) async {
    // Prevents duplicate listeners on the same blog-list stream when
    // refreshing the list.
    await _listSliceSubscription?.cancel();

    if (state.blogs.isEmpty) {
      emit(
        const BlogListLoading(
          blogs: [],
          nextCursor: null,
          isFromCache: false,
          refreshError: null,
        ),
      );
    } else {
      emit(
        BlogListSuccess(
          blogs: state.blogs,
          nextCursor: state.nextCursor,
          isFromCache: state.isFromCache,
          refreshError: null,
        ),
      );
    }
    _listSliceSubscription = _observeInitialBlogListSliceUseCase().listen(
      (result) => add(_InitialListSliceReceived(result)),
    );
  }

  Future<void> _onRefreshList(
    RefreshList event,
    Emitter<BlogListState> emit,
  ) async {
    add(const LoadInitialList());
  }

  void _onPrependCreatedBlog(
    PrependCreatedBlog event,
    Emitter<BlogListState> emit,
  ) {
    final updatedBlogs = [
      event.blog,
      ...state.blogs.where((blog) => blog.id != event.blog.id),
    ];

    emit(
      BlogListSuccess(
        blogs: updatedBlogs,
        nextCursor: state.nextCursor,
        isFromCache: state.isFromCache,
        refreshError: state.refreshError,
      ),
    );
  }

  Future<void> _onLoadMoreList(
    LoadMoreList event,
    Emitter<BlogListState> emit,
  ) async {
    if (state is BlogListLoading) {
      return;
    }

    final cursor = state.nextCursor;
    if (cursor == null) {
      return;
    }

    final existingBlogs = state.blogs;
    final nextCursor = state.nextCursor;
    final isFromCache = state.isFromCache;

    emit(
      BlogListLoading(
        blogs: existingBlogs,
        nextCursor: nextCursor,
        isFromCache: isFromCache,
        refreshError: null,
      ),
    );

    final result = await _getBlogListSliceUseCase(
      GetBlogListSliceParams(
        limit: _pageSize,
        cursor: cursor,
      ),
    );

    result.fold(
      (failure) {
        emit(
          BlogListSuccess(
            blogs: existingBlogs,
            nextCursor: nextCursor,
            isFromCache: isFromCache,
            refreshError: failure.message,
          ),
        );
      },
      (listSlice) {
        emit(
          BlogListSuccess(
            blogs: _mergeBlogs(
              existingBlogs: existingBlogs,
              listSlice: listSlice,
            ),
            nextCursor: listSlice.nextCursor,
            isFromCache: listSlice.source == BlogListSource.cache,
            refreshError: listSlice.refreshFailure?.message,
          ),
        );
      },
    );
  }

  void _onInitialListSliceReceived(
    _InitialListSliceReceived event,
    Emitter<BlogListState> emit,
  ) {
    event.result.fold(
      (failure) {
        if (state.blogs.isEmpty) {
          emit(
            BlogListFailure(
              error: failure.message,
              blogs: state.blogs,
              nextCursor: state.nextCursor,
              isFromCache: false,
              refreshError: null,
            ),
          );
          return;
        }

        emit(
          BlogListSuccess(
            blogs: state.blogs,
            nextCursor: state.nextCursor,
            isFromCache: state.isFromCache,
            refreshError: failure.message,
          ),
        );
      },
      (listSlice) {
        emit(
          BlogListSuccess(
            blogs: listSlice.blogs,
            nextCursor: listSlice.nextCursor,
            isFromCache: listSlice.source == BlogListSource.cache,
            refreshError: listSlice.refreshFailure?.message,
          ),
        );
      },
    );
  }

  List<Blog> _mergeBlogs({
    required List<Blog> existingBlogs,
    required BlogListSlice listSlice,
  }) {
    return [
      ...existingBlogs,
      ...listSlice.blogs.where(
        (blog) =>
            existingBlogs.every((existingBlog) => existingBlog.id != blog.id),
      ),
    ];
  }
}
