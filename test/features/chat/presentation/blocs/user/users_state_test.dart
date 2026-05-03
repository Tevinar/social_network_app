import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/presentation/blocs/user/users_bloc.dart';

void main() {
  const user = UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com');

  test('given UsersLoading when it is created then it exposes its values', () {
    const state = UsersLoading(
      users: [user],
      pageNumber: 1,
      totalUsersInDatabase: 2,
    );

    expect(state.users, const [user]);
    expect(state.pageNumber, 1);
    expect(state.totalUsersInDatabase, 2);
  });

  test('given UsersSuccess when it is created then it exposes its values', () {
    const state = UsersSuccess(
      users: [user],
      pageNumber: 2,
      totalUsersInDatabase: 2,
    );

    expect(state.users, const [user]);
    expect(state.pageNumber, 2);
    expect(state.totalUsersInDatabase, 2);
  });

  test('given UsersFailure when it is created then it exposes its values', () {
    const state = UsersFailure(
      error: 'boom',
      users: [user],
      pageNumber: 3,
      totalUsersInDatabase: 4,
    );

    expect(state.error, 'boom');
    expect(state.users, const [user]);
    expect(state.pageNumber, 3);
    expect(state.totalUsersInDatabase, 4);
  });
}
