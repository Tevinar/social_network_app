part of '../routes.dart';

@TypedGoRoute<SignInPageRoute>(path: '/sign-in')
/// A route for sign in page.
class SignInPageRoute extends GoRouteData with $SignInPageRoute {
  /// Creates a [SignInPageRoute].
  const SignInPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignInPage();
}

@TypedGoRoute<SignUpPageRoute>(path: '/sign-up')
/// A route for sign up page.
class SignUpPageRoute extends GoRouteData with $SignUpPageRoute {
  /// Creates a [SignUpPageRoute].
  const SignUpPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}
