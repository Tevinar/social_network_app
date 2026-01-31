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

  BlogsState copyWith({
    List<Blog>? blogs,
    int? pageNumber,
    int? totalBlogsInDatabase,
  }) {
    return switch (this) {
      BlogsLoading() => BlogsLoading(
        blogs: blogs ?? this.blogs,
        pageNumber: pageNumber ?? this.pageNumber,
        totalBlogsInDatabase: totalBlogsInDatabase ?? this.totalBlogsInDatabase,
      ),

      BlogsSuccess() => BlogsSuccess(
        blogs: blogs ?? this.blogs,
        pageNumber: pageNumber ?? this.pageNumber,
        totalBlogsInDatabase: totalBlogsInDatabase ?? this.totalBlogsInDatabase,
      ),

      BlogsFailure(:final error) => BlogsFailure(
        error: error,
        blogs: blogs ?? this.blogs,
        pageNumber: pageNumber ?? this.pageNumber,
        totalBlogsInDatabase: totalBlogsInDatabase ?? this.totalBlogsInDatabase,
      ),
    };
  }
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
