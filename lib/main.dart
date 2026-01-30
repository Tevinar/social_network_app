import 'package:bloc_app/core/common/presentation/cubits/app_user/app_user_cubit.dart';
import 'package:bloc_app/core/theme/theme.dart';
import 'package:bloc_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:bloc_app/dependencies/init_dependencies.dart';
import 'package:bloc_app/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:bloc_app/features/chat/presentation/blocs/user/user_list_bloc.dart';
import 'package:bloc_app/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  /**
   * 
   * WidgetsFlutterBinding is a Flutter framework component that acts as the glue between the 
   * Flutter framework and the underlying platform. It's responsible for handling the 
   * interaction between Flutter widgets and the native platform services.
   * 
   * This method ensures that the Flutter framework is properly initialized before 
   * running any asynchronous operations in your main() function.
   * 
   */
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (context) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (context) => serviceLocator<BlogBloc>()),
        BlocProvider(create: (context) => serviceLocator<ChatBloc>()),
        BlocProvider(create: (context) => serviceLocator<UserListBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // Retrieve current user data if connected and save this data into current AuthBloc state and into AppUserCubit state
    BlocProvider.of<AuthBloc>(context).add(AuthCurrentUser());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.darkThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
