part of '../routes.dart';

@TypedGoRoute<AddNewBlogPageRoute>(path: '/add-new-blog')
/// A route for add new blog page.
class AddNewBlogPageRoute extends GoRouteData with $AddNewBlogPageRoute {
  /// Creates a [AddNewBlogPageRoute].
  const AddNewBlogPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddNewBlogPage();
}

@TypedGoRoute<BlogViewerPageRoute>(path: '/blog-viewer')
/// A route for blog viewer page.
class BlogViewerPageRoute extends GoRouteData with $BlogViewerPageRoute {
  /// Creates a [BlogViewerPageRoute].
  const BlogViewerPageRoute({required this.blogId});

  /// The extra.
  final String blogId;

  @override
  Widget build(BuildContext context, GoRouterState state) => BlogViewerPage(
    blogId: blogId,
  );
}
