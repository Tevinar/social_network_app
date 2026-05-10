part of 'init_dependencies.dart';

/// The service locator.
final GetIt serviceLocator = GetIt.instance;

/// The init dependencies.
Future<void> initDependencies() async {
  _initDio();

  // app
  _initApp();

  // core
  _initCore();

  // features
  _initAuth();
  _initBlog();
  _initChat();
}

/// Registers the application's HTTP clients.
///
/// We keep two separate `Dio` instances:
/// - `publicDio` for requests that must not require an access token
/// - `authedDio` for requests that automatically attach and refresh auth
///   credentials
///
/// The authenticated client also accepts the local self-signed certificate in
/// debug mode so simulator traffic can follow backend redirects to the local
/// HTTPS asset host during development.
void _initDio() {
  serviceLocator
    // Public client used for unauthenticated endpoints such as sign-in,
    // sign-up, and token refresh.
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: Env.backendBaseUrl,
          headers: {'content-type': 'application/json'},
        ),
      ),
      instanceName: 'publicDio',
    )
    // Authenticated client used by protected feature APIs.
    ..registerLazySingleton<Dio>(
      () {
        final dio = Dio(
          BaseOptions(
            baseUrl: Env.backendBaseUrl,
            headers: {'content-type': 'application/json'},
          ),
        );

        // Attach bearer tokens to outgoing requests and retry once after an
        // auth refresh when the backend reports an expired session.
        dio.interceptors.add(
          AuthDioInterceptor(
            dio: dio,
            authTokenManager: serviceLocator(),
          ),
        );

        // The blog image endpoint redirects to a local HTTPS asset host in
        // development. iOS simulator requests will fail that redirect unless
        // the local self-signed certificate is explicitly accepted.
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient()
            ..badCertificateCallback = (cert, host, port) {
              // Restrict this exception to local development hosts only.
              return kDebugMode && (host == '127.0.0.1' || host == 'localhost');
            };
          return client;
        };

        return dio;
      },
      instanceName: 'authedDio',
    );
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
    ..registerLazySingleton(
      () => DioHttpDownloader(serviceLocator(instanceName: 'authedDio')),
    )
    ..registerLazySingleton<ImageFileCache>(
      () => ImageFileCacheImpl(
        dioHttpDownloader: serviceLocator(),
      ),
    );
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
    ..registerLazySingleton(
      () => HttpSseClient(
        baseUrl: Env.backendBaseUrl,
        authTokenManager: serviceLocator(),
      ),
    )
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
    ..registerLazySingleton(
      () => CreateChatUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatListSliceUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatMessageListSliceUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => CreateChatMessageUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatByMembersUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatCandidateListSliceUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => SubscribeToChatListUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => SubscribeToChatMessageListUseCase(chatRepository: serviceLocator()),
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
      () => ChatListBloc(
        getChatListSlice: serviceLocator(),
        subscribeToChatList: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChatMessagesBloc(
        getChatMessageListSlice: serviceLocator(),
        subscribeToChatMessageList: serviceLocator(),
        createChatMessage: serviceLocator(),
      ),
    );
}
