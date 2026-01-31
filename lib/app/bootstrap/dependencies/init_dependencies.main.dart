part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  Supabase supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
  _initAuth();
  _initBlog();
  _initChat();

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());

  serviceLocator.registerLazySingleton(() => InternetConnection());
  serviceLocator.registerLazySingleton<ConnectionChecker>(
    () => ConnectionCheckerImpl(internetConnection: serviceLocator()),
  );
}

void _initAuth() {
  serviceLocator
    // Datasources
    // We need to specify that '<AuthRemoteDataSource>' because the parameter 'authRemoteDataSource' from 'AuthRepositoryImpl'
    // require an object of type 'AuthRemoteDataSource' and not an object of type 'AuthRemoteDataSourceSupabaseImpl'.
    // If we don't specify this, GetIt won't be able to find this reference when creating a AuthRepositoryImpl instance.
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceSupabaseImpl(serviceLocator()),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(() => UserSignUp(authRepository: serviceLocator()))
    ..registerLazySingleton(() => UserSignIn(authRepositoy: serviceLocator()))
    ..registerLazySingleton(() => CurrentUser(authRepository: serviceLocator()))
    ..registerLazySingleton(() => UserSignOut(authRepository: serviceLocator()))
    // BLoC
    ..registerLazySingleton(
      () => AuthBloc(
        userSignOut: serviceLocator(),
        userSignUp: serviceLocator(),
        userSignIn: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // ..registerLazySingleton<BlogLocalDataSource>(//
    //   () => BlogLocalDataSourceImpl(serviceLocator()),
    // )
    // Repositories
    ..registerLazySingleton<BlogRepository>(
      () => BlogRepositoryImpl(
        blogRemoteDataSource: serviceLocator(),
        // blogLocalDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(() => CreateBlog(blogRepository: serviceLocator()))
    ..registerLazySingleton(
      () => GetBlogsPage(blogRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetBlogsCount(blogRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(() => BlogEditorBloc(uploadBlog: serviceLocator()))
    ..registerLazySingleton(
      () => BlogsBloc(
        getBlogsPage: serviceLocator(),
        getBlogsCount: serviceLocator(),
        repository: serviceLocator(),
      ),
    );
}

void _initChat() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    ..registerLazySingleton<UsersRemoteDataSource>(
      () => UsersRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // Repositories
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(chatRemoteDataSource: serviceLocator()),
    )
    ..registerLazySingleton<UsersRepository>(
      () => UsersRepositoryImpl(usersRemoteDataSource: serviceLocator()),
    )
    // Usecases
    ..registerLazySingleton(() => CreateChat(chatRepository: serviceLocator()))
    ..registerLazySingleton(
      () => GetUsersPage(usersRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetUsersCount(usersRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(() => ChatBloc(createChat: serviceLocator()))
    ..registerLazySingleton(
      () => UsersBloc(
        getUsersPage: serviceLocator(),
        getUsersCount: serviceLocator(),
      ),
    );
}
