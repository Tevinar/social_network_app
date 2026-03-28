import 'package:social_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An users remote data source.
abstract interface class UsersRemoteDataSource {
  /// The get users page.
  Future<List<UserModel>> getUsersPage(int pageNumber);

  /// The get users count.
  Future<int> getUsersCount();
}

/// An users remote data source impl.
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  /// Creates a [UsersRemoteDataSourceImpl].
  UsersRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;
  final SupabaseClient _supabaseClient;

  @override
  Future<List<UserModel>> getUsersPage(int pageNumber) async {
    return guardRemoteDataSourceCall(() async {
      const pageSize = 20;
      final from = (pageNumber - 1) * pageSize;
      final to = from + pageSize - 1;

      final response = await _supabaseClient
          .from(Tables.profiles)
          .select()
          .range(from, to)
          .order(ProfileFields.name, ascending: true);

      return response.map(UserModel.fromProfileJson).toList();
    });
  }

  @override
  Future<int> getUsersCount() async {
    return guardRemoteDataSourceCall(() async {
      return await _supabaseClient.from(Tables.profiles).count();
    });
  }
}
