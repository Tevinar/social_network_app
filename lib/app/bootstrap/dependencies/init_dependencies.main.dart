part of 'init_dependencies.dart';

/// The service locator.
final GetIt serviceLocator = GetIt.instance;

/// The init dependencies.
Future<void> initDependencies() async {
  // Shared public config is committed for zero-config onboarding.
  await dotenv.load(fileName: 'assets/config/env.public');
  final supabase = await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  // app
  _initApp();

  // core
  _initCore();

  // features
  _initAuth();
  _initBlog();
  _initChat();
}

void _initApp() {
  // Session
  serviceLocator
    ..registerLazySingleton(
      () => AppUserCubit(
        authRepository: serviceLocator(),
        userSignOut: serviceLocator(),
      ),
    )
    // logging
    ..registerLazySingleton(createTalker)
    ..registerLazySingleton<AppLogger>(
      () => AppTalkerLogger(talker: serviceLocator()),
    );
}

void _initCore() {
  // Connection checker
  serviceLocator
    ..registerLazySingleton(InternetConnection.new)
    ..registerLazySingleton<ConnectionChecker>(
      () => ConnectionCheckerImpl(internetConnection: serviceLocator()),
    )
    // Image picker service
    ..registerLazySingleton(ImagePicker.new)
    ..registerLazySingleton<ImagePickerService>(
      () => ImagePickerServiceImpl(serviceLocator()),
    );
}

void _initAuth() {
  serviceLocator
    // Datasources
    // We register the interface type because AuthRepositoryImpl depends on
    // AuthRemoteDataSource, not on AuthRemoteDataSourceSupabaseImpl directly.
    // Without this explicit type, GetIt could not resolve the dependency.
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceSupabaseImpl(serviceLocator()),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(authRemoteDataSource: serviceLocator()),
    )
    // Usecases
    ..registerLazySingleton(() => UserSignUp(authRepository: serviceLocator()))
    ..registerLazySingleton(() => UserSignIn(authRepositoy: serviceLocator()))
    ..registerLazySingleton(() => UserSignOut(authRepository: serviceLocator()))
    // BLoC
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSignIn: serviceLocator(),
        authRepository: serviceLocator(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // Repositories
    ..registerLazySingleton<BlogRepository>(
      () => BlogRepositoryImpl(blogRemoteDataSource: serviceLocator()),
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
    ..registerLazySingleton<ChatMessageRemoteDataSource>(
      () => ChatMessageRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // Repositories
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(chatRemoteDataSource: serviceLocator()),
    )
    ..registerLazySingleton<UsersRepository>(
      () => UsersRepositoryImpl(usersRemoteDataSource: serviceLocator()),
    )
    ..registerLazySingleton<ChatMessageRepository>(
      () => ChatMessageRepositoryImpl(
        chatMessageRemoteDataSource: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(() => CreateChat(chatRepository: serviceLocator()))
    ..registerLazySingleton(
      () => GetUsersPage(usersRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetUsersCount(usersRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatsCount(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatsPage(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatMessagesPage(chatMessageRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatMessagesCount(chatMessageRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => CreateChatMessage(chatMessageRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatByMembers(chatRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(
      () => ChatEditorBloc(
        createChat: serviceLocator(),
        getChatByMembers: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => UsersBloc(
        getUsersPage: serviceLocator(),
        getUsersCount: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ChatsBloc(
        getChatsPage: serviceLocator(),
        getChatsCount: serviceLocator(),
        repository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChatMessagesBloc(
        getChatMessagesPage: serviceLocator(),
        getChatMessagesCount: serviceLocator(),
        repository: serviceLocator(),
        createChatMessage: serviceLocator(),
      ),
    );
}
