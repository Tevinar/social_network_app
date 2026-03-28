import 'package:social_app/features/blog/domain/entities/blog.dart';

sealed class BlogChange {}

class BlogInserted extends BlogChange {
  BlogInserted(this.blog);
  final Blog blog;
}

class BlogUpdated extends BlogChange {
  BlogUpdated(this.blog);
  final Blog blog;
}

class BlogDeleted extends BlogChange {
  BlogDeleted(this.blogId);
  final String blogId;
}
