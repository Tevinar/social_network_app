import 'package:bloc_app/app/bootstrap/initial_loading_page.dart';
import 'package:bloc_app/features/auth/presentation/pages/signin_page.dart';
import 'package:bloc_app/features/auth/presentation/pages/signup_page.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:bloc_app/features/blog/presentation/pages/blogs_page.dart';
import 'package:bloc_app/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:bloc_app/features/chat/presentation/pages/chats_page.dart';
import 'package:bloc_app/features/chat/presentation/pages/new_chat_page.dart';
import 'package:bloc_app/app/router/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'router_config.g.dart';

@TypedGoRoute<SignInPageRoute>(path: '/signInPage')
class SignInPageRoute extends GoRouteData with $SignInPageRoute {
  const SignInPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignInPage();
}

@TypedGoRoute<SignUpPageRoute>(path: '/signUpPage')
class SignUpPageRoute extends GoRouteData with $SignUpPageRoute {
  const SignUpPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}

@TypedGoRoute<LoadingPageRoute>(path: '/loadingPage')
class LoadingPageRoute extends GoRouteData with $LoadingPageRoute {
  const LoadingPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InitialLoadingPage();
}

class BlogPageRoute extends GoRouteData with $BlogPageRoute {
  const BlogPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const BlogsPage();
}

@TypedGoRoute<AddNewBlogPageRoute>(path: '/addNewBlogPage')
class AddNewBlogPageRoute extends GoRouteData with $AddNewBlogPageRoute {
  const AddNewBlogPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddNewBlogPage();
}

@TypedGoRoute<BlogViewerPageRoute>(path: '/blogViewerPage')
class BlogViewerPageRoute extends GoRouteData with $BlogViewerPageRoute {
  final Blog $extra;
  const BlogViewerPageRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BlogViewerPage(blog: $extra);
}

class ChatsPageRoute extends GoRouteData with $ChatsPageRoute {
  const ChatsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ChatsPage();
}

@TypedGoRoute<NewChatPageRoute>(path: '/newChatPage')
class NewChatPageRoute extends GoRouteData with $NewChatPageRoute {
  const NewChatPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NewChatPage();
}

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    // Blogs Tab
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<BlogPageRoute>(path: '/')],
    ),
    // Chats Tab
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChatsPageRoute>(path: '/chatsPage'),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppNavigationBar(navigationShell: navigationShell);
  // Return the widget that implements the custom shell (in this case
  // using a BottomNavigationBar). The StatefulNavigationShell is passed
  // to be able access the state of the shell and to navigate to other
  // branches in a stateful way.
}
