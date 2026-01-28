// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_config.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $signInPageRoute,
  $signUpPageRoute,
  $loadingPageRoute,
  $appShellRouteData,
];

RouteBase get $signInPageRoute => GoRouteData.$route(
  path: '/signInPage',
  factory: $SignInPageRoute._fromState,
);

mixin $SignInPageRoute on GoRouteData {
  static SignInPageRoute _fromState(GoRouterState state) =>
      const SignInPageRoute();

  @override
  String get location => GoRouteData.$location('/signInPage');

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

RouteBase get $signUpPageRoute => GoRouteData.$route(
  path: '/signUpPage',
  factory: $SignUpPageRoute._fromState,
);

mixin $SignUpPageRoute on GoRouteData {
  static SignUpPageRoute _fromState(GoRouterState state) =>
      const SignUpPageRoute();

  @override
  String get location => GoRouteData.$location('/signUpPage');

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

RouteBase get $loadingPageRoute => GoRouteData.$route(
  path: '/loadingPage',
  factory: $LoadingPageRoute._fromState,
);

mixin $LoadingPageRoute on GoRouteData {
  static LoadingPageRoute _fromState(GoRouterState state) =>
      const LoadingPageRoute();

  @override
  String get location => GoRouteData.$location('/loadingPage');

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

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/',
          factory: $BlogPageRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'addNewBlogPage',
              factory: $AddNewBlogPageRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'blogViewerPage',
              factory: $BlogViewerPageRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/chatsPage',
          factory: $ChatsPageRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'newChatPage',
              factory: $NewChatPageRoute._fromState,
            ),
          ],
        ),
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

mixin $AddNewBlogPageRoute on GoRouteData {
  static AddNewBlogPageRoute _fromState(GoRouterState state) =>
      const AddNewBlogPageRoute();

  @override
  String get location => GoRouteData.$location('/addNewBlogPage');

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

mixin $BlogViewerPageRoute on GoRouteData {
  static BlogViewerPageRoute _fromState(GoRouterState state) =>
      BlogViewerPageRoute($extra: state.extra as Blog);

  BlogViewerPageRoute get _self => this as BlogViewerPageRoute;

  @override
  String get location => GoRouteData.$location('/blogViewerPage');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $ChatsPageRoute on GoRouteData {
  static ChatsPageRoute _fromState(GoRouterState state) =>
      const ChatsPageRoute();

  @override
  String get location => GoRouteData.$location('/chatsPage');

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

mixin $NewChatPageRoute on GoRouteData {
  static NewChatPageRoute _fromState(GoRouterState state) =>
      const NewChatPageRoute();

  @override
  String get location => GoRouteData.$location('/chatsPage/newChatPage');

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
