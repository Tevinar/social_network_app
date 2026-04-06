// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $appShellRouteData,
  $initialLoadingPageRoute,
  $signInPageRoute,
  $signUpPageRoute,
  $addNewBlogPageRoute,
  $blogViewerPageRoute,
  $newChatPageRoute,
  $chatMessagesPageRoute,
];

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(path: '/', factory: $BlogPageRoute._fromState),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(path: '/chats', factory: $ChatsPageRoute._fromState),
      ],
    ),
  ],
);

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

mixin $BlogPageRoute on GoRouteData {
  static BlogPageRoute _fromState(GoRouterState state) => const BlogPageRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ChatsPageRoute on GoRouteData {
  static ChatsPageRoute _fromState(GoRouterState state) =>
      const ChatsPageRoute();

  @override
  String get location => GoRouteData.$location('/chats');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $initialLoadingPageRoute => GoRouteData.$route(
  path: '/initial-loading',
  factory: $InitialLoadingPageRoute._fromState,
);

mixin $InitialLoadingPageRoute on GoRouteData {
  static InitialLoadingPageRoute _fromState(GoRouterState state) =>
      const InitialLoadingPageRoute();

  @override
  String get location => GoRouteData.$location('/initial-loading');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInPageRoute =>
    GoRouteData.$route(path: '/sign-in', factory: $SignInPageRoute._fromState);

mixin $SignInPageRoute on GoRouteData {
  static SignInPageRoute _fromState(GoRouterState state) =>
      const SignInPageRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpPageRoute =>
    GoRouteData.$route(path: '/sign-up', factory: $SignUpPageRoute._fromState);

mixin $SignUpPageRoute on GoRouteData {
  static SignUpPageRoute _fromState(GoRouterState state) =>
      const SignUpPageRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $addNewBlogPageRoute => GoRouteData.$route(
  path: '/add-new-blog',
  factory: $AddNewBlogPageRoute._fromState,
);

mixin $AddNewBlogPageRoute on GoRouteData {
  static AddNewBlogPageRoute _fromState(GoRouterState state) =>
      const AddNewBlogPageRoute();

  @override
  String get location => GoRouteData.$location('/add-new-blog');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $blogViewerPageRoute => GoRouteData.$route(
  path: '/blog-viewer',
  factory: $BlogViewerPageRoute._fromState,
);

mixin $BlogViewerPageRoute on GoRouteData {
  static BlogViewerPageRoute _fromState(GoRouterState state) =>
      BlogViewerPageRoute(blogId: state.uri.queryParameters['blog-id']!);

  BlogViewerPageRoute get _self => this as BlogViewerPageRoute;

  @override
  String get location => GoRouteData.$location(
    '/blog-viewer',
    queryParams: {'blog-id': _self.blogId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $newChatPageRoute => GoRouteData.$route(
  path: '/new-chat',
  factory: $NewChatPageRoute._fromState,
);

mixin $NewChatPageRoute on GoRouteData {
  static NewChatPageRoute _fromState(GoRouterState state) =>
      const NewChatPageRoute();

  @override
  String get location => GoRouteData.$location('/new-chat');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatMessagesPageRoute => GoRouteData.$route(
  path: '/chat-messages',
  factory: $ChatMessagesPageRoute._fromState,
);

mixin $ChatMessagesPageRoute on GoRouteData {
  static ChatMessagesPageRoute _fromState(GoRouterState state) =>
      const ChatMessagesPageRoute();

  @override
  String get location => GoRouteData.$location('/chat-messages');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
