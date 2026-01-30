import 'package:bloc_app/core/common/data/models/user_model.dart';
import 'package:bloc_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/tables.dart';
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UserListRemoteDataSource {
  Future<List<UserModel>> getUsersByPage(int pageNumber);
}

class UserListRemoteDataSourceImpl implements UserListRemoteDataSource {
  final SupabaseClient _supabaseClient;

  UserListRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<List<UserModel>> getUsersByPage(int pageNumber) async {
    try {
      if (pageNumber < 1) {
        throw ArgumentError('pageNumber must be >= 1');
      }
      const int pageSize = 20;
      final int from = (pageNumber - 1) * pageSize;
      final int to = from + pageSize - 1;

      final List<Map<String, dynamic>> response = await _supabaseClient
          .from(Tables.profiles)
          .select()
          .range(from, to)
          .order(ProfileFields.name, ascending: true);

      return response
          .map((Map<String, dynamic> json) => UserModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
