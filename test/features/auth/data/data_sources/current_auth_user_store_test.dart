import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/data/sources/local/current_auth_user_store.dart';

void main() {
  late AppDatabase database;
  late DriftCurrentAuthUserStore store;

  const firstUser = UserModel(
    id: 'user-1',
    name: 'First User',
    email: 'first@example.com',
  );
  const secondUser = UserModel(
    id: 'user-2',
    name: 'Second User',
    email: 'second@example.com',
  );

  setUp(() {
    database = AppDatabase.test(NativeDatabase.memory());
    store = DriftCurrentAuthUserStore(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('watchCurrentUser', () {
    test(
      'given no stored user when watching then emits null followed by saved '
      'user changes',
      () async {
        // Arrange
        final emitted = <UserModel?>[];
        final subscription = store.watchCurrentUser().listen(emitted.add);
        await pumpEventQueue();

        // Act
        await store.saveCurrentUser(firstUser);
        await pumpEventQueue();

        // Assert
        expect(emitted, hasLength(2));
        expect(emitted.first, isNull);
        expect(emitted.last?.id, firstUser.id);
        expect(emitted.last?.name, firstUser.name);
        expect(emitted.last?.email, firstUser.email);

        await subscription.cancel();
      },
    );

    test(
      'given a stored user when it is cleared then emits null and later saves '
      'overwrite the singleton row',
      () async {
        // Arrange
        await store.saveCurrentUser(firstUser);
        final emitted = <UserModel?>[];
        final subscription = store.watchCurrentUser().listen(emitted.add);
        await pumpEventQueue();

        // Act
        await store.clearCurrentUser();
        await pumpEventQueue();
        await store.saveCurrentUser(secondUser);
        await pumpEventQueue();

        // Assert
        expect(emitted, hasLength(3));
        expect(emitted.first?.id, firstUser.id);
        expect(emitted[1], isNull);
        expect(emitted.last?.id, secondUser.id);
        expect(emitted.last?.name, secondUser.name);

        await subscription.cancel();
      },
    );
  });
}
