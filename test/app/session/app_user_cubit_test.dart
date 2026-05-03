import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/auth/domain/usecases/user_sign_out_use_case.dart';
import 'package:social_app/features/auth/domain/usecases/watch_auth_state_changes_use_case.dart';

class MockUserSignOut extends Mock implements UserSignOutUseCase {}

class MockWatchAuthStateChanges extends Mock implements WatchAuthStateChanges {}

void main() {
  late MockUserSignOut mockUserSignOut;
  late MockWatchAuthStateChanges mockWatchAuthStateChanges;

  const testUser = UserEntity(
    id: '123',
    name: 'Test User',
    email: 'test@test.com',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockUserSignOut = MockUserSignOut();
    mockWatchAuthStateChanges = MockWatchAuthStateChanges();

    when(
      () => mockWatchAuthStateChanges(any()),
    ).thenAnswer((_) => const Stream.empty());
  });

  test(
    'given an AppUserCubit when it is created then it is in '
    'AppUserLoading state',
    () {
      // Arrange
      final appUserCubit = AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
      addTearDown(appUserCubit.close);

      // Assert
      expect(appUserCubit.state, isA<AppUserLoading>());
    },
  );

  blocTest<AppUserCubit, AppUserState>(
    'given authStateChanges emits Right(null) when the cubit listens then '
    'emits AppUserSignedOut',
    build: () {
      // Arrange
      when(
        () => mockWatchAuthStateChanges(any()),
      ).thenAnswer((_) => Stream.value(const Right(null)));

      // Act
      return AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
    },
    expect: () => [
      // Assert
      isA<AppUserSignedOut>(),
    ],
  );

  blocTest<AppUserCubit, AppUserState>(
    'given authStateChanges emits Right(user) when the cubit listens then '
    'emits AppUserSignedIn',
    build: () {
      // Arrange
      when(
        () => mockWatchAuthStateChanges(any()),
      ).thenAnswer((_) => Stream.value(const Right(testUser)));

      // Act
      return AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
    },
    expect: () => [
      // Assert
      isA<AppUserSignedIn>()
          .having((state) => state.user.id, 'user.id', testUser.id)
          .having((state) => state.user.name, 'user.name', testUser.name)
          .having((state) => state.user.email, 'user.email', testUser.email),
    ],
  );

  blocTest<AppUserCubit, AppUserState>(
    'given authStateChanges emits Left(failure) when the cubit listens then '
    'emits AppUserFailure',
    build: () {
      const failure = NetworkFailure();
      // Arrange
      when(
        () => mockWatchAuthStateChanges(any()),
      ).thenAnswer((_) => Stream.value(left(failure)));

      // Act
      return AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
    },
    expect: () => [
      // Assert
      isA<AppUserFailure>().having(
        (state) => state.error,
        'error',
        'No internet connection.',
      ),
    ],
  );

  blocTest<AppUserCubit, AppUserState>(
    'given signOut succeeds when signOut is called then emits '
    'AppUserLoading and AppUserSignedOut',
    build: () {
      // Arrange
      when(
        () => mockUserSignOut(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      return AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
    },
    act: (cubit) {
      // Act
      return cubit.signOut();
    },
    expect: () => [
      // Assert
      isA<AppUserLoading>(),
      isA<AppUserSignedOut>(),
    ],
  );

  blocTest<AppUserCubit, AppUserState>(
    'given signOut fails when signOut is called then emits AppUserLoading '
    'and AppUserFailure',
    build: () {
      const failure = UnauthorizedFailure();
      // Arrange
      when(
        () => mockUserSignOut(any()),
      ).thenAnswer((_) async => left(failure));

      return AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
    },
    act: (cubit) {
      // Act
      return cubit.signOut();
    },
    expect: () => [
      // Assert
      isA<AppUserLoading>(),
      isA<AppUserFailure>().having(
        (state) => state.error,
        'error',
        'Your session has expired. Please sign in again.',
      ),
    ],
  );

  test(
    'given signOut is called when the cubit invokes the use case then calls '
    'UserSignOut with NoParams',
    () async {
      // Arrange
      when(
        () => mockUserSignOut(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final appUserCubit = AppUserCubit(
        userSignOut: mockUserSignOut,
        watchAuthStateChanges: mockWatchAuthStateChanges,
      );
      addTearDown(appUserCubit.close);

      // Act
      await appUserCubit.signOut();

      // Assert
      verify(
        () => mockUserSignOut(any(that: isA<NoParams>())),
      ).called(1);
    },
  );
}
