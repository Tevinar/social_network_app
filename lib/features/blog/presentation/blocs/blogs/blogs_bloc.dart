import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/usecases/get_blogs_count.dart';
import 'package:bloc_app/features/blog/domain/usecases/get_blogs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'blogs_event.dart';
part 'blogs_state.dart';

class BlogsBloc extends Bloc<BlogsEvent, BlogsState> {
  final ScrollController _scrollController = ScrollController();
  final GetBlogsPage _getBlogsPage;
  final GetBlogsCount _getBlogsCount;
  BlogsBloc({
    required GetBlogsPage getBlogsPage,
    required GetBlogsCount getBlogsCount,
  }) : _getBlogsPage = getBlogsPage,
       _getBlogsCount = getBlogsCount,
       super(const BlogsLoading(blogs: [], pageNumber: 1)) {
    _addListenerToScrollController();
    on<LoadBlogsNextPage>(_onLoadBlogsNextPage);
    add(LoadBlogsNextPage());
  }

  // Add a listener to scrollController events
  // and fetch more blogs when reaching the bottom
  void _addListenerToScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        add(LoadBlogsNextPage());
      }
    });
  }

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
