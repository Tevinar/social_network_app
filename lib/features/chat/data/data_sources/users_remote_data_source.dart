import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/core/constants/error_messages.dart';
import 'package:bloc_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/tables.dart';
import 'package:bloc_app/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UsersRemoteDataSource {
  Future<List<UserModel>> getUsersPage(int pageNumber);
  Future<int> getUsersCount();
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final SupabaseClient _supabaseClient;

  UsersRemoteDataSourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<List<UserModel>> getUsersPage(int pageNumber) async {
    try {
      if (pageNumber < 1) {
        throw ArgumentError(ErrorMessages.pageNumberInvalid);
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

  @override
  Future<int> getUsersCount() async {
    try {
      return await _supabaseClient.from(Tables.profiles).count();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
