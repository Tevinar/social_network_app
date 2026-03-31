import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/blogs_bloc.dart';
import 'package:social_app/features/blog/presentation/pages/blogs_page.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card_place_holder.dart';

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

class MockBlogsBloc extends MockBloc<BlogsEvent, BlogsState>
    implements BlogsBloc {}

void main() {
  late MockAppUserCubit appUserCubit;
  late MockBlogsBloc blogsBloc;
  late ScrollController scrollController;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUpAll(() {
    registerFallbackValue(RefreshBlogsView());
  });

  setUp(() {
    appUserCubit = MockAppUserCubit();
    blogsBloc = MockBlogsBloc();
    scrollController = ScrollController();

    when(() => blogsBloc.scrollController).thenReturn(scrollController);
    when(() => blogsBloc.scrollToTop()).thenAnswer((_) async {});
    when(() => appUserCubit.signOut()).thenAnswer((_) async {});
  });

  Widget buildTestableWidget({
    required AppUserState appUserState,
    required BlogsState blogsState,
  }) {
    when(() => appUserCubit.state).thenReturn(appUserState);
    when(() => blogsBloc.state).thenReturn(blogsState);
    whenListen(appUserCubit, Stream.value(appUserState));
    whenListen(blogsBloc, Stream.value(blogsState));

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppUserCubit>.value(value: appUserCubit),
          BlocProvider<BlogsBloc>.value(value: blogsBloc),
        ],
        child: const BlogsPage(),
      ),
    );
  }

  Widget buildRoutableWidget({
    required BlogsState blogsState,
    required AppUserState appUserState,
  }) {
    when(() => appUserCubit.state).thenReturn(appUserState);
    when(() => blogsBloc.state).thenReturn(blogsState);
    whenListen(appUserCubit, Stream.value(appUserState));
    whenListen(blogsBloc, Stream.value(blogsState));

    final router = GoRouter(
      initialLocation: '/blogs',
      routes: [
        GoRoute(
          path: '/blogs',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppUserCubit>.value(value: appUserCubit),
              BlocProvider<BlogsBloc>.value(value: blogsBloc),
            ],
            child: const BlogsPage(),
          ),
        ),
        GoRoute(
          path: '/add-new-blog',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Complete'),
            ),
          ),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows a loader while the app user is loading', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: AppUserLoading(),
        blogsState: const BlogsSuccess(
          blogs: [],
          pageNumber: 1,
          totalBlogsInDatabase: 0,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsNothing);
  });

  testWidgets('calls signOut when the logout button is tapped', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: const AppUserSignedIn(
          User(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
        ),
        blogsState: const BlogsSuccess(
          blogs: [],
          pageNumber: 1,
          totalBlogsInDatabase: 0,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();

    verify(() => appUserCubit.signOut()).called(1);
  });

  testWidgets('shows a snackbar when AppUserFailure is emitted', (
    tester,
  ) async {
    when(() => appUserCubit.state).thenReturn(AppUserSignedOut());
    when(() => blogsBloc.state).thenReturn(
      const BlogsSuccess(blogs: [], pageNumber: 1, totalBlogsInDatabase: 0),
    );
    whenListen(
      appUserCubit,
      Stream.fromIterable([
        AppUserSignedOut(),
        const AppUserFailure('Sign out failed'),
      ]),
    );
    whenListen(
      blogsBloc,
      Stream.value(
        const BlogsSuccess(blogs: [], pageNumber: 1, totalBlogsInDatabase: 0),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AppUserCubit>.value(value: appUserCubit),
            BlocProvider<BlogsBloc>.value(value: blogsBloc),
          ],
          child: const BlogsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Sign out failed'), findsOneWidget);
  });

  testWidgets('shows the failure body when blogs loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: AppUserSignedOut(),
        blogsState: const BlogsFailure(
          error: 'boom',
          blogs: [],
          pageNumber: 1,
        ),
      ),
    );

    expect(find.text('Error loading blogs'), findsOneWidget);
  });

  testWidgets('shows placeholders while the first page is loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: AppUserSignedOut(),
        blogsState: const BlogsLoading(blogs: [], pageNumber: 1),
      ),
    );

    expect(find.byType(BlogCardPlaceholder), findsNWidgets(4));
  });

  testWidgets('shows the list of blogs and a loader for the next page', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        appUserState: AppUserSignedOut(),
        blogsState: BlogsSuccess(
          blogs: [blog],
          pageNumber: 2,
          totalBlogsInDatabase: 2,
        ),
      ),
    );

    expect(find.byType(BlogCard), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets(
    'when the add flow returns true then it scrolls to top and refreshes '
    'the view',
    (tester) async {
      await tester.pumpWidget(
        buildRoutableWidget(
          appUserState: AppUserSignedOut(),
          blogsState: BlogsSuccess(
            blogs: [blog],
            pageNumber: 2,
            totalBlogsInDatabase: 1,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      verify(() => blogsBloc.scrollToTop()).called(1);
      verify(() => blogsBloc.add(any(that: isA<RefreshBlogsView>()))).called(1);
    },
  );
}
