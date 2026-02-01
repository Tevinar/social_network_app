part of '../routes.dart';

@TypedGoRoute<AddNewBlogPageRoute>(path: '/add-new-blog')
class AddNewBlogPageRoute extends GoRouteData with $AddNewBlogPageRoute {
  const AddNewBlogPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddNewBlogPage();
}

@TypedGoRoute<BlogViewerPageRoute>(path: '/blog-viewer')
class BlogViewerPageRoute extends GoRouteData with $BlogViewerPageRoute {
  final Blog $extra;
  const BlogViewerPageRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BlogViewerPage(blog: $extra);
}
