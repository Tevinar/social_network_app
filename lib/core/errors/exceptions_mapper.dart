import 'dart:io';

import 'package:social_app/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The guard remote data source call.
Future<T> guardRemoteDataSourceCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on PostgrestException catch (e) {
    throw ServerException(message: e.message, code: e.code);
  } on SocketException catch (e) {
    throw NetworkException(message: e.message);
  } catch (e) {
    throw ServerException(message: e.toString());
  }
}
