part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Shared public config is committed for zero-config onboarding.
  await dotenv.load(fileName: 'assets/config/env.public');
  final Supabase supabase = await Supabase.initialize(
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
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(
      authRepository: serviceLocator(),
      userSignOut: serviceLocator(),
    ),
  );
  // logging
  serviceLocator.registerLazySingleton(createTalker);
  serviceLocator.registerLazySingleton<AppLogger>(
    () => AppTalkerLogger(talker: serviceLocator()),
  );
}

void _initCore() {
  // Connection checker
  serviceLocator.registerLazySingleton(InternetConnection.new);
  serviceLocator.registerLazySingleton<ConnectionChecker>(
    () => ConnectionCheckerImpl(internetConnection: serviceLocator()),
  );

  // Image picker service
  serviceLocator.registerLazySingleton(ImagePicker.new);
  serviceLocator.registerLazySingleton<ImagePickerService>(
    () => ImagePickerServiceImpl(serviceLocator()),
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
    ..registerLazySingleton(
      () => ChatMessagesBloc(
        getChatMessagesPage: serviceLocator(),
        getChatMessagesCount: serviceLocator(),
        repository: serviceLocator(),
        createChatMessage: serviceLocator(),
      ),
    );
}
