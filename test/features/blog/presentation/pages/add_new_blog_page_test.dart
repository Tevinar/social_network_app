import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/app/media/image_picker_service.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_editor/blog_editor_bloc.dart';
import 'package:social_app/features/blog/presentation/pages/add_new_blog_page.dart';

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

class MockBlogEditorBloc extends MockBloc<BlogEditorEvent, BlogEditorState>
    implements BlogEditorBloc {}

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockAppUserCubit appUserCubit;
  late MockBlogEditorBloc blogEditorBloc;
  late MockImagePickerService imagePickerService;
  late MockAppLogger appLogger;
  late File imageFile;

  setUpAll(() {
    registerFallbackValue(
      AddBlog(
        posterId: '',
        posterName: '',
        title: '',
        content: '',
        image: File('/tmp/fallback.png'),
        topics: const [],
      ),
    );
  });

  setUp(() async {
    await GetIt.I.reset();
    appUserCubit = MockAppUserCubit();
    blogEditorBloc = MockBlogEditorBloc();
    imagePickerService = MockImagePickerService();
    appLogger = MockAppLogger();
    GetIt.I.registerSingleton<ImagePickerService>(imagePickerService);
    GetIt.I.registerSingleton<AppLogger>(appLogger);

    imageFile = File(
      '${Directory.systemTemp.path}/blog_test_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await imageFile.writeAsBytes(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Zx1kAAAAASUVORK5CYII=',
      ),
    );
  });

  tearDown(() async {
    if (imageFile.existsSync()) {
      await imageFile.delete();
    }
    await GetIt.I.reset();
  });

  Widget buildTestableWidget({
    required AppUserState appUserState,
    required BlogEditorState blogEditorState,
  }) {
    when(() => appUserCubit.state).thenReturn(appUserState);
    when(() => blogEditorBloc.state).thenReturn(blogEditorState);
    whenListen(appUserCubit, Stream.value(appUserState));
    whenListen(blogEditorBloc, Stream.value(blogEditorState));

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppUserCubit>.value(value: appUserCubit),
          BlocProvider<BlogEditorBloc>.value(value: blogEditorBloc),
        ],
        child: const AddNewBlogPage(),
      ),
    );
  }

  testWidgets('renders the empty editor state', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: const AppUserSignedIn(
          UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
        ),
        blogEditorState: BlogInitial(),
      ),
    );

    expect(find.text('Select your image'), findsOneWidget);
    expect(find.text('Blog title'), findsOneWidget);
    expect(find.text('Blog content'), findsOneWidget);
  });

  testWidgets('shows a snackbar when upload is triggered without an image', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: const AppUserSignedIn(
          UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
        ),
        blogEditorState: BlogInitial(),
      ),
    );

    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Please select an image'), findsOneWidget);
  });

  testWidgets(
    'shows a snackbar when image selection fails',
    (tester) async {
      when(
        () => imagePickerService.pickFromGallery(),
      ).thenThrow(Exception('boom'));

      await tester.pumpWidget(
        buildTestableWidget(
          appUserState: const AppUserSignedIn(
            UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
          ),
          blogEditorState: BlogInitial(),
        ),
      );

      await tester.tap(find.text('Select your image'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Failed to pick image'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a loader while the image picker is in flight and then renders '
    'the image',
    (tester) async {
      final completer = Completer<XFile?>();
      when(
        () => imagePickerService.pickFromGallery(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildTestableWidget(
          appUserState: const AppUserSignedIn(
            UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
          ),
          blogEditorState: BlogInitial(),
        ),
      );

      await tester.tap(find.text('Select your image'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(XFile(imageFile.path));
      await tester.pumpAndSettle();

      expect(find.text('Select your image'), findsNothing);
      expect(find.byType(Image), findsWidgets);
    },
  );

  testWidgets(
    'shows a snackbar when upload is triggered without topics',
    (tester) async {
      when(
        () => imagePickerService.pickFromGallery(),
      ).thenAnswer((_) async => XFile(imageFile.path));

      await tester.pumpWidget(
        buildTestableWidget(
          appUserState: const AppUserSignedIn(
            UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
          ),
          blogEditorState: BlogInitial(),
        ),
      );

      await tester.tap(find.text('Select your image'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.done_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Please select at least one topic'), findsOneWidget);
    },
  );

  testWidgets(
    'removes a selected topic when it is tapped a second time',
    (tester) async {
      when(
        () => imagePickerService.pickFromGallery(),
      ).thenAnswer((_) async => XFile(imageFile.path));

      await tester.pumpWidget(
        buildTestableWidget(
          appUserState: const AppUserSignedIn(
            UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
          ),
          blogEditorState: BlogInitial(),
        ),
      );

      await tester.tap(find.text('Select your image'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Technology'));
      await tester.pump();
      await tester.tap(find.text('Technology'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.done_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Please select at least one topic'), findsOneWidget);
    },
  );

  testWidgets('validates the form before dispatching AddBlog', (tester) async {
    when(
      () => imagePickerService.pickFromGallery(),
    ).thenAnswer((_) async => XFile(imageFile.path));

    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: const AppUserSignedIn(
          UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
        ),
        blogEditorState: BlogInitial(),
      ),
    );

    await tester.tap(find.text('Select your image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technology'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pump();

    expect(find.text('Blog title is missing'), findsOneWidget);
    expect(find.text('Blog content is missing'), findsOneWidget);
    verifyNever(() => blogEditorBloc.add(any()));
  });

  testWidgets('shows a snackbar when the user is signed out', (tester) async {
    when(
      () => imagePickerService.pickFromGallery(),
    ).thenAnswer((_) async => XFile(imageFile.path));

    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: AppUserSignedOut(),
        blogEditorState: BlogInitial(),
      ),
    );

    await tester.tap(find.text('Select your image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technology'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), '  Title  ');
    await tester.enterText(find.byType(TextFormField).at(1), '  Content  ');
    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('You must be signed in to add a blog'), findsOneWidget);
  });

  testWidgets('dispatches AddBlog with trimmed values when the form is valid', (
    tester,
  ) async {
    when(
      () => imagePickerService.pickFromGallery(),
    ).thenAnswer((_) async => XFile(imageFile.path));

    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: const AppUserSignedIn(
          UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
        ),
        blogEditorState: BlogInitial(),
      ),
    );

    await tester.tap(find.text('Select your image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technology'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), '  Title  ');
    await tester.enterText(find.byType(TextFormField).at(1), '  Content  ');
    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pump();

    verify(
      () => blogEditorBloc.add(
        any(
          that: isA<AddBlog>()
              .having((event) => event.posterId, 'posterId', 'user-1')
              .having((event) => event.posterName, 'posterName', 'Alice')
              .having((event) => event.title, 'title', 'Title')
              .having((event) => event.content, 'content', 'Content')
              .having(
                (event) => event.topics,
                'topics',
                const [BlogTopic.technology],
              )
              .having(
                (event) => event.image.path,
                'image.path',
                imageFile.path,
              ),
        ),
      ),
    ).called(1);
  });

  testWidgets('shows a snackbar when BlogFailure is emitted', (tester) async {
    when(() => appUserCubit.state).thenReturn(
      const AppUserSignedIn(
        UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
      ),
    );
    when(() => blogEditorBloc.state).thenReturn(BlogInitial());
    whenListen(appUserCubit, Stream.value(appUserCubit.state));
    whenListen(
      blogEditorBloc,
      Stream.fromIterable([
        BlogInitial(),
        BlogFailure('Upload failed'),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AppUserCubit>.value(value: appUserCubit),
            BlocProvider<BlogEditorBloc>.value(value: blogEditorBloc),
          ],
          child: const AddNewBlogPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Upload failed'), findsOneWidget);
  });

  testWidgets('shows a loader in the app bar while BlogLoading is active', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: const AppUserSignedIn(
          UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
        ),
        blogEditorState: BlogLoading(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('pops back when BlogUploadSuccess is emitted', (tester) async {
    when(() => appUserCubit.state).thenReturn(
      const AppUserSignedIn(
        UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
      ),
    );
    when(() => blogEditorBloc.state).thenReturn(BlogInitial());
    whenListen(appUserCubit, Stream.value(appUserCubit.state));
    whenListen(
      blogEditorBloc,
      Stream.fromIterable([BlogInitial(), BlogUploadSuccess()]),
    );

    final router = GoRouter(
      initialLocation: '/blogs',
      routes: [
        GoRoute(
          path: '/blogs',
          builder: (context, state) => Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/add-new-blog'),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/add-new-blog',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppUserCubit>.value(value: appUserCubit),
              BlocProvider<BlogEditorBloc>.value(value: blogEditorBloc),
            ],
            child: const AddNewBlogPage(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.byType(AddNewBlogPage), findsNothing);
  });
}
