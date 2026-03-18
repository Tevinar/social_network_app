import 'package:social_app/features/blog/domain/entities/blog.dart';

sealed class BlogChange {}

class BlogInserted extends BlogChange {
  final Blog blog;
  BlogInserted(this.blog);
}

class BlogUpdated extends BlogChange {
  final Blog blog;
  BlogUpdated(this.blog);
}

class BlogDeleted extends BlogChange {
  final String blogId;
  BlogDeleted(this.blogId);
}
