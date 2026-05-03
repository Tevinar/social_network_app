part of 'init_dependencies.dart';

/// The service locator.
final GetIt serviceLocator = GetIt.instance;

/// The init dependencies.
Future<void> initDependencies() async {
  serviceLocator.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: Env.backendBaseUrl,
        headers: {'content-type': 'application/json'},
      ),
    ),
  );

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
        userSignOut: serviceLocator(),
        watchAuthStateChanges: serviceLocator(),
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
    ..registerLazySingleton(AppDatabase.new)
    ..registerLazySingleton(InternetConnection.new)
    ..registerLazySingleton<ConnectionChecker>(
      () => ConnectionCheckerImpl(internetConnection: serviceLocator()),
    )
    ..registerLazySingleton<ImageFileCache>(ImageFileCacheImpl.new)
    // Image picker service
    ..registerLazySingleton(ImagePicker.new)
    ..registerLazySingleton<ImagePickerService>(
      () => ImagePickerServiceImpl(serviceLocator()),
    );
}

void _initAuth() {
  serviceLocator
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton<AuthSessionStore>(
      () => SecureAuthSessionStore(serviceLocator()),
    )
    ..registerLazySingleton<AppSettingsStore>(
      () => DriftAppSettingsStore(serviceLocator()),
    )
    // Datasources
    // We register the interface type because AuthRepositoryImpl depends on
    // AuthRemoteDataSource, not on AuthRemoteDataSourceSupabaseImpl directly.
    // Without this explicit type, GetIt could not resolve the dependency.
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        appSettingsStore: serviceLocator(),
        dio: serviceLocator(),
        authSessionStore: serviceLocator(),
      ),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: serviceLocator(),
        authSessionStore: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(
      () => UserSignUpUseCase(authRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => UserSignInUseCase(authRepositoy: serviceLocator()),
    )
    ..registerLazySingleton(
      () => UserSignOutUseCase(authRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => WatchAuthStateChanges(authRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUpUseCase: serviceLocator(),
        userSignInUseCase: serviceLocator(),
        watchAuthStateChangesUseCase: serviceLocator(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<BlogLocalDataSource>(
      () => BlogLocalDataSourceDriftImpl(database: serviceLocator()),
    )
    ..registerLazySingleton<SseClient>(
      () => HttpSseClient(
        baseUrl: Env.backendBaseUrl,
        authSessionStore: serviceLocator(),
      ),
    )
    ..registerLazySingleton<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        dio: serviceLocator(),
        sseClient: serviceLocator(),
      ),
    )
    // Repositories
    ..registerLazySingleton<BlogRepository>(
      () => BlogRepositoryImpl(
        blogRemoteDataSource: serviceLocator(),
        blogLocalDataSource: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(
      () => CreateBlogUseCase(blogRepository: serviceLocator()),
    )
    ..registerLazySingleton(() => GetBlogByIdUseCase(serviceLocator()))
    ..registerLazySingleton(
      () => WatchFeedSliceUseCase(blogRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => WatchFeedEventsUseCase(blogRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(() => BlogEditorBloc(uploadBlog: serviceLocator()))
    ..registerLazySingleton(
      () => BlogFeedBloc(
        watchFeedSliceUseCase: serviceLocator(),
        watchFeedEventsUseCase: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => BlogViewerBloc(getBlogByIdUseCase: serviceLocator()),
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
    ..registerLazySingleton(
      () => WatchChatChanges(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => WatchChatMessageChanges(chatMessageRepository: serviceLocator()),
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
        watchChatChanges: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChatMessagesBloc(
        getChatMessagesPage: serviceLocator(),
        getChatMessagesCount: serviceLocator(),
        watchChatMessageChanges: serviceLocator(),
        createChatMessage: serviceLocator(),
      ),
    );
}
