import 'package:social_app/features/blog/domain/entities/blog.dart';

/// Represents blog change.
sealed class BlogChange {}

/// A blog inserted.
class BlogInserted extends BlogChange {
  /// Creates a [BlogInserted].
  BlogInserted(this.blog);

  /// The blog.
  final Blog blog;
}

/// A blog updated.
class BlogUpdated extends BlogChange {
  /// Creates a [BlogUpdated].
  BlogUpdated(this.blog);

  /// The blog.
  final Blog blog;
}

/// A blog deleted.
class BlogDeleted extends BlogChange {
  /// Creates a [BlogDeleted].
  BlogDeleted(this.blogId);

  /// The blog id.
  final String blogId;
}
