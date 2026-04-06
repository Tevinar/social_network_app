part of 'blog_viewer_bloc.dart';

sealed class BlogViewerEvent {
  const BlogViewerEvent();
}

class LoadBlog extends BlogViewerEvent {
  final String? blogId;
  final List<Blog>? blogs;

  LoadBlog({this.blogId, this.blogs});
}
