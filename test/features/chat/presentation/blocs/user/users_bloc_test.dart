import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_users_page.dart';
import 'package:social_app/features/chat/presentation/blocs/user/users_bloc.dart';

class MockGetUsersPage extends Mock implements GetUsersPage {}

class MockGetUsersCount extends Mock implements GetUsersCount {}

void main() {
  late MockGetUsersPage getUsersPage;
  late MockGetUsersCount getUsersCount;

  const user = User(id: 'user-1', name: 'Alice', email: 'alice@test.com');
  const user2 = User(id: 'user-2', name: 'Bob', email: 'bob@test.com');

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getUsersPage = MockGetUsersPage();
    getUsersCount = MockGetUsersCount();
  });

  test(
    'given the bloc is created when reading state then state is UsersLoading',
    () {
      when(() => getUsersCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getUsersPage(any())).thenAnswer((_) async => const Right([]));

      final bloc = UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
      addTearDown(bloc.close);

      expect(bloc.state, isA<UsersLoading>());
    },
  );

  blocTest<UsersBloc, UsersState>(
    'given the initial load succeeds when the bloc is created then it emits '
    'loading states and success',
    build: () {
      when(() => getUsersCount(any())).thenAnswer((_) async => const Right(1));
      when(() => getUsersPage(1)).thenAnswer((_) async => const Right([user]));
      return UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
    },
    expect: () => [
      isA<UsersLoading>(),
      isA<UsersLoading>(),
      isA<UsersSuccess>()
          .having((state) => state.users, 'users', const [user])
          .having((state) => state.pageNumber, 'pageNumber', 2),
    ],
  );

  blocTest<UsersBloc, UsersState>(
    'given getUsersCount fails when the initial load runs then it emits '
    'failure before continuing',
    build: () {
      when(
        () => getUsersCount(any()),
      ).thenAnswer((_) async => left(const NetworkFailure()));
      when(() => getUsersPage(1)).thenAnswer((_) async => const Right([user]));
      return UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
    },
    expect: () => [
      isA<UsersFailure>().having(
        (state) => state.error,
        'error',
        'No internet connection.',
      ),
      isA<UsersLoading>(),
      isA<UsersSuccess>(),
    ],
  );

  blocTest<UsersBloc, UsersState>(
    'given getUsersPage fails when loading a page then it emits UsersFailure',
    build: () {
      when(() => getUsersCount(any())).thenAnswer((_) async => const Right(2));
      when(
        () => getUsersPage(1),
      ).thenAnswer((_) async => left(const ValidationFailure('boom')));
      return UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
    },
    expect: () => [
      isA<UsersLoading>(),
      isA<UsersLoading>(),
      isA<UsersFailure>().having((state) => state.error, 'error', 'boom'),
    ],
  );

  blocTest<UsersBloc, UsersState>(
    'given all users are already loaded when LoadUsersNextPage is added '
    'then it emits nothing',
    build: () {
      when(() => getUsersCount(any())).thenAnswer((_) async => const Right(1));
      when(() => getUsersPage(1)).thenAnswer((_) async => const Right([user]));
      return UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
    },
    seed: () => const UsersSuccess(
      users: [user],
      pageNumber: 2,
      totalUsersInDatabase: 1,
    ),
    act: (bloc) => bloc.add(LoadUsersNextPage()),
    expect: () => <UsersState>[],
  );

  blocTest<UsersBloc, UsersState>(
    'given users are already loading when LoadUsersNextPage is added then '
    'it emits nothing',
    build: () {
      when(() => getUsersCount(any())).thenAnswer((_) async => const Right(2));
      when(() => getUsersPage(1)).thenAnswer((_) async => const Right([user]));
      return UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
    },
    seed: () => const UsersLoading(
      users: [user],
      pageNumber: 2,
      totalUsersInDatabase: 2,
    ),
    act: (bloc) => bloc.add(LoadUsersNextPage()),
    expect: () => <UsersState>[],
  );

  testWidgets(
    'given the scroll controller is near the bottom when the list scrolls '
    'then it loads the next page',
    (tester) async {
      when(() => getUsersCount(any())).thenAnswer((_) async => const Right(3));
      when(() => getUsersPage(1)).thenAnswer((_) async => const Right([user]));
      when(() => getUsersPage(2)).thenAnswer((_) async => const Right([user2]));

      final bloc = UsersBloc(
        getUsersPage: getUsersPage,
        getUsersCount: getUsersCount,
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: bloc.scrollController,
            itemCount: 30,
            itemBuilder: (context, index) => const SizedBox(height: 100),
          ),
        ),
      );
      await tester.pump();

      bloc.scrollController.jumpTo(
        bloc.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      verify(() => getUsersPage(2)).called(1);
    },
  );
}
