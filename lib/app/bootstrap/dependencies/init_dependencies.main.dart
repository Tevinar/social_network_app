part of 'init_dependencies.dart';

/// The service locator.
final GetIt serviceLocator = GetIt.instance;

/// The init dependencies.
Future<void> initDependencies() async {
  serviceLocator
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: Env.backendBaseUrl,
          headers: {'content-type': 'application/json'},
        ),
      ),
      instanceName: 'publicDio',
    )
    ..registerLazySingleton<Dio>(
      () {
        final dio = Dio(
          BaseOptions(
            baseUrl: Env.backendBaseUrl,
            headers: {'content-type': 'application/json'},
          ),
        );

        dio.interceptors.add(
          AuthDioInterceptor(
            dio: dio,
            authTokenManager: serviceLocator(),
          ),
        );

        return dio;
      },
      instanceName: 'authedDio',
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
    ..registerLazySingleton<ImageFileCache>(ImageFileCacheImpl.new);
}

void _initAuth() {
  serviceLocator
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton<AuthSessionStore>(
      () => SecureAuthSessionStore(serviceLocator()),
    )
    ..registerLazySingleton<CurrentAuthUserStore>(
      () => DriftCurrentAuthUserStore(serviceLocator()),
    )
    ..registerLazySingleton<AppSettingsStore>(
      () => DriftAppSettingsStore(serviceLocator()),
    )
    ..registerLazySingleton(
      () => BackendAuthSessionRefresher(
        dio: serviceLocator(instanceName: 'publicDio'),
        appSettingsStore: serviceLocator(),
        authSessionStore: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => AuthTokenManager(
        authSessionStore: serviceLocator(),
        currentAuthUserStore: serviceLocator(),
        authSessionRefresher: serviceLocator(),
      ),
    )
    // Datasources
    // We register the interface type because AuthRepositoryImpl depends on
    // AuthRemoteDataSource, not on AuthRemoteDataSourceSupabaseImpl directly.
    // Without this explicit type, GetIt could not resolve the dependency.
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        appSettingsStore: serviceLocator(),
        dio: serviceLocator(instanceName: 'publicDio'),
        authSessionStore: serviceLocator(),
      ),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: serviceLocator(),
        authSessionStore: serviceLocator(),
        currentAuthUserStore: serviceLocator(),
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
        authTokenManager: serviceLocator(),
      ),
    )
    ..registerLazySingleton<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        dio: serviceLocator(instanceName: 'authedDio'),
      ),
    )
    // Repositories
    ..registerLazySingleton<BlogRepository>(
      () => BlogRepositoryImpl(
        blogRemoteDataSource: serviceLocator(),
        blogLocalDataSource: serviceLocator(),
        imageFileCache: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(
      () => CreateBlogUseCase(blogRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetBlogImageUseCase(blogRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ObserveInitialBlogListSliceUseCase(
        blogRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => GetBlogListSliceUseCase(blogRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ObserveBlogByIdUseCase(serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(() => BlogEditorBloc(uploadBlog: serviceLocator()))
    ..registerLazySingleton(
      () => BlogListBloc(
        observeInitialBlogListSliceUseCase: serviceLocator(),
        getBlogListSliceUseCase: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => BlogViewerBloc(
        observeBlogByIdUseCase: serviceLocator(),
        getBlogImageUseCase: serviceLocator(),
      ),
    );
}

void _initChat() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        dio: serviceLocator(instanceName: 'authedDio'),
        sseClient: serviceLocator(),
      ),
    )
    // Repositories
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(chatRemoteDataSource: serviceLocator()),
    )
    // Usecases
    ..registerLazySingleton(() => CreateChat(chatRepository: serviceLocator()))
    ..registerLazySingleton(
      () => GetUsersPage(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetUsersCount(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatsCount(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatsPage(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatMessagesPage(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatMessagesCount(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => CreateChatMessage(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatByMembers(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatCandidateListSlice(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => SubscribeToChatList(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => SubscribeToChatMessageList(chatRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(
      () => ChatEditorBloc(
        createChat: serviceLocator(),
        getChatByMembers: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ChatCandidateListBloc(
        getChatCandidateListSlice: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ChatsBloc(
        getChatsPage: serviceLocator(),
        getChatsCount: serviceLocator(),
        subscribeToChatList: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChatMessagesBloc(
        getChatMessagesPage: serviceLocator(),
        getChatMessagesCount: serviceLocator(),
        subscribeToChatMessageList: serviceLocator(),
        createChatMessage: serviceLocator(),
      ),
    );
}
