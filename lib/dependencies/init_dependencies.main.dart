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
  //Hive initialization
  // Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path; TODO to remove

  //serviceLocator.registerLazySingleton(() => Hive.box(name: 'blogs'));TODO to remove

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
    ..registerLazySingleton(() => UploadBlog(blogRepository: serviceLocator()))
    ..registerLazySingleton(() => GetAllBlogs(blogRepository: serviceLocator()))
    // BLoC
    ..registerLazySingleton(
      () =>
          BlogBloc(uploadBlog: serviceLocator(), getAllBlogs: serviceLocator()),
    );
}

void _initChat() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    ..registerLazySingleton<UserListRemoteDataSource>(
      () => UserListRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // Repositories
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(chatRemoteDataSource: serviceLocator()),
    )
    ..registerLazySingleton<UserListRepository>(
      () => UserListRepositoryImpl(userListRemoteDataSource: serviceLocator()),
    )
    // Usecases
    ..registerLazySingleton(() => CreateChat(chatRepository: serviceLocator()))
    ..registerLazySingleton(
      () => GetUsersByPage(userListRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(() => ChatBloc(createChat: serviceLocator()))
    ..registerLazySingleton(
      () => UserListBloc(getUsersByPage: serviceLocator()),
    );
}
