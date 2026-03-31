import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/chat/data/data_sources/users_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient supabaseClient;
  late UsersRemoteDataSourceImpl dataSource;
  late FakeSupabaseQueryBuilder queryBuilder;
  late FakeListBuilder listBuilder;
  late FakeInsertBuilder insertBuilder;
  late FakeIntBuilder countBuilder;

  setUp(() {
    supabaseClient = MockSupabaseClient();
    listBuilder = FakeListBuilder(
      result: const [
        <String, dynamic>{'id': 'user-1', 'name': 'Alice'},
      ],
    );
    insertBuilder = FakeInsertBuilder(listBuilder);
    countBuilder = FakeIntBuilder(5);
    queryBuilder = FakeSupabaseQueryBuilder(
      selectBuilder: listBuilder,
      insertBuilder: insertBuilder,
      countBuilder: countBuilder,
    );

    dataSource = UsersRemoteDataSourceImpl(supabaseClient: supabaseClient);

    when(
      () => supabaseClient.from(Tables.profiles),
    ).thenAnswer((_) => queryBuilder);
  });

  test(
    'given a page number when getUsersPage is called then returns a mapped '
    'page of users',
    () async {
      // Act
      final result = await dataSource.getUsersPage(2);

      // Assert
      expect(listBuilder.rangeFrom, 20);
      expect(listBuilder.rangeTo, 39);
      expect(listBuilder.orderColumn, ProfileFields.name);
      expect(listBuilder.orderAscending, isTrue);
      expect(result.single.id, 'user-1');
      expect(result.single.name, 'Alice');
    },
  );

  test(
    'given getUsersCount is called then returns the remote count',
    () async {
      // Act
      final result = await dataSource.getUsersCount();

      // Assert
      expect(result, 5);
    },
  );

  test(
    'given a network error when getUsersPage is called then throws '
    'NetworkException',
    () async {
      // Arrange
      when(
        () => supabaseClient.from(Tables.profiles),
      ).thenThrow(const SocketException('offline'));

      // Act
      final result = dataSource.getUsersPage(1);

      // Assert
      await expectLater(result, throwsA(isA<NetworkException>()));
    },
  );
}
