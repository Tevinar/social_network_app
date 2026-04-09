import 'package:flutter/material.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/router/app_router.dart';
import 'package:social_app/app/widgets/offline_startup_snackbar.dart';
import 'package:social_app/core/theme/theme.dart';

/// A social app.
class SocialApp extends StatelessWidget {
  /// Creates a [SocialApp].
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Social App',
      theme: AppTheme.darkThemeMode,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return OfflineStartupSnackbar(
          connectionChecker: serviceLocator(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
