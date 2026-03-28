part of 'blogs_bloc.dart';

@immutable
/// Represents blogs state.
sealed class BlogsState {
  const BlogsState({
    required this.blogs,
    required this.pageNumber,
    this.totalBlogsInDatabase,
  });

  /// The blogs.
  final List<Blog> blogs;

  /// The int.
  final int pageNumber;

  /// The int.
  final int? totalBlogsInDatabase;

  /// The copy with.
  BlogsState copyWith({
    /// The blogs.
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

/// A blogs loading.
final class BlogsLoading extends BlogsState {
  /// Creates a [BlogsLoading].
  const BlogsLoading({
    required super.blogs,
    required super.pageNumber,
    super.totalBlogsInDatabase,
  });
}

/// A blogs success.
final class BlogsSuccess extends BlogsState {
  /// Creates a [BlogsSuccess].
  const BlogsSuccess({
    required super.blogs,
    required super.pageNumber,
    super.totalBlogsInDatabase,
  });
}

/// Represents blogs failure.
final class BlogsFailure extends BlogsState {
  /// Creates a [BlogsFailure].
  const BlogsFailure({
    required this.error,
    required super.blogs,
    required super.pageNumber,
    super.totalBlogsInDatabase,
  });

  /// The error.
  final String error;
}
