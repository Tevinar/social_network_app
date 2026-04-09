import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
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
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUpAll(() {
    registerFallbackValue(RefreshBlogsView());
  });

  setUp(() async {
    await GetIt.I.reset();
    appUserCubit = MockAppUserCubit();
    blogsBloc = MockBlogsBloc();
    scrollController = ScrollController();

    serviceLocator.registerFactory<BlogsBloc>(() => blogsBloc);

    when(() => appUserCubit.signOut()).thenAnswer((_) async {});
    when(() => blogsBloc.scrollController).thenReturn(scrollController);
    when(() => blogsBloc.scrollToTop()).thenAnswer((_) async {});
    when(() => blogsBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    scrollController.dispose();
    await GetIt.I.reset();
  });

  Widget buildTestableWidget({
    required BlogsState blogsState,
    AppUserState? appUserState,
  }) {
    final resolvedAppUserState = appUserState ?? AppUserSignedOut();

    when(() => appUserCubit.state).thenReturn(resolvedAppUserState);
    whenListen(
      appUserCubit,
      Stream.value(resolvedAppUserState),
      initialState: resolvedAppUserState,
    );
    when(() => blogsBloc.state).thenReturn(blogsState);
    whenListen(blogsBloc, Stream.value(blogsState), initialState: blogsState);

    return MaterialApp(
      home: BlocProvider<AppUserCubit>.value(
        value: appUserCubit,
        child: const BlogsPage(),
      ),
    );
  }

  Widget buildRoutableWidget({
    required BlogsState blogsState,
    AppUserState? appUserState,
  }) {
    final resolvedAppUserState = appUserState ?? AppUserSignedOut();

    when(() => appUserCubit.state).thenReturn(resolvedAppUserState);
    whenListen(
      appUserCubit,
      Stream.value(resolvedAppUserState),
      initialState: resolvedAppUserState,
    );
    when(() => blogsBloc.state).thenReturn(blogsState);
    whenListen(blogsBloc, Stream.value(blogsState), initialState: blogsState);

    final router = GoRouter(
      initialLocation: '/blogs',
      routes: [
        GoRoute(
          path: '/blogs',
          builder: (context, state) => BlocProvider<AppUserCubit>.value(
            value: appUserCubit,
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

  testWidgets('shows placeholders while the first page is loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        blogsState: const BlogsLoading(blogs: [], pageNumber: 1),
      ),
    );

    expect(find.byType(BlogCardPlaceholder), findsNWidgets(4));
  });

  testWidgets('shows the failure body when blogs loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        blogsState: const BlogsFailure(
          error: 'boom',
          blogs: [],
          pageNumber: 1,
        ),
      ),
    );

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('shows the list of blogs and a loader for the next page', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        blogsState: BlogsSuccess(
          blogs: [blog],
          pageNumber: 2,
          totalBlogsInDatabase: 2,
        ),
      ),
    );

    expect(find.byType(BlogCard), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'when the add flow returns true then it scrolls to top and refreshes '
    'the view',
    (tester) async {
      await tester.pumpWidget(
        buildRoutableWidget(
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
