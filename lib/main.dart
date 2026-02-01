import 'package:bloc_app/app/session/app_user_cubit.dart';
import 'package:bloc_app/core/theme/theme.dart';
import 'package:bloc_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_app/features/blog/presentation/blocs/blog/blog_editor_bloc.dart';
import 'package:bloc_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:bloc_app/features/blog/presentation/blocs/blogs/blogs_bloc.dart';
import 'package:bloc_app/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:bloc_app/features/chat/presentation/blocs/user/users_bloc.dart';
import 'package:bloc_app/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  /// WidgetsFlutterBinding is a Flutter framework component that acts as the glue between the
  /// Flutter framework and the underlying platform. It's responsible for handling the
  /// interaction between Flutter widgets and the native platform services.
  ///
  /// This method ensures that the Flutter framework is properly initialized before
  /// running any asynchronous operations in your main() function.
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (context) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (context) => serviceLocator<BlogEditorBloc>()),
        BlocProvider(create: (context) => serviceLocator<BlogsBloc>()),
        BlocProvider(create: (context) => serviceLocator<ChatBloc>()),
        BlocProvider(create: (context) => serviceLocator<UsersBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Social Network App',
      theme: AppTheme.darkThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
