part of 'blogs_bloc.dart';

@immutable
sealed class BlogsState {
  final List<Blog> blogs;
  final int pageNumber;
  final int? totalBlogsInDatabase;

  const BlogsState({
    required this.blogs,
    required this.pageNumber,
    this.totalBlogsInDatabase,
  });
}

final class BlogsLoading extends BlogsState {
  const BlogsLoading({
    required super.blogs,
    required super.pageNumber,
    super.totalBlogsInDatabase,
  });
}

final class BlogsSuccess extends BlogsState {
  const BlogsSuccess({
    required super.blogs,
    required super.pageNumber,
    super.totalBlogsInDatabase,
  });
}

final class BlogsFailure extends BlogsState {
  final String error;

  const BlogsFailure({
    required this.error,
    required super.blogs,
    required super.pageNumber,
    super.totalBlogsInDatabase,
  });
}
