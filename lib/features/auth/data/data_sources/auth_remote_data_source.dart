import 'package:social_network_app/core/constants/error_messages.dart';
import 'package:social_network_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:social_network_app/core/errors/exceptions.dart';
import 'package:social_network_app/core/errors/exceptions_mapper.dart';
import 'package:social_network_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Creation of an abstract class to respect dependendy inversion principle. Therefore, if
// we later want to switch Supabase for, for example, Firebase, we can be creating a new class
// that implement AuthRemoteDataSource
abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<UserModel?> authStateChanges();
}

class AuthRemoteDataSourceSupabaseImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const AuthRemoteDataSourceSupabaseImpl(this._supabaseClient);

  @override
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return guardRemoteDataSourceCall(() async {
      final response = await _supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw const ServerException(message: ErrorMessages.userNull);
      }
      return UserModel.fromAuthJson(response.user!.toJson());
    });
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return guardRemoteDataSourceCall(() async {
      final response = await _supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {ProfileFields.name: name},
      );
      if (response.user == null) {
        throw const ServerException(message: ErrorMessages.userNull);
      }
      return UserModel.fromAuthJson(response.user!.toJson());
    });
  }

  @override
  Future<void> signOut() async {
    return guardRemoteDataSourceCall(() async {
      await _supabaseClient.auth.signOut();
    });
  }

  /// Emits authentication state changes as a stream of [UserModel].
  ///
  /// This method exposes Supabase Auth's real-time authentication stream and
  /// adapts it to the application's data layer by mapping vendor payloads into
  /// [UserModel].
  ///
  /// ### Execution boundary ownership (important)
  /// Unlike Future-based remote methods, this method does **not own the execution
  /// lifecycle** of the operation. Supabase Auth owns the stream and may emit
  /// events or errors asynchronously, long after this method has returned.
  ///
  /// For this reason, this method **must not translate errors** into custom
  /// infrastructure exceptions (e.g. `ServerException`), as doing so would
  /// interfere with the upstream stream lifecycle.
  ///
  /// ### Emitted values
  /// - Emits a non-null [UserModel] when a user is authenticated
  /// - Emits `null` when the user signs out or when no active session exists
  ///
  /// `null` represents a **valid signed-out state**, not an error.
  ///
  /// ### Error handling responsibility
  /// - Errors emitted by Supabase Auth are allowed to propagate as stream errors
  /// - Translation of vendor errors into infrastructure exceptions or domain
  ///   failures is handled by the **repository layer**
  ///
  /// This ensures:
  /// - long-lived stream stability
  /// - correct distinction between logout and error states
  /// - proper ownership of error semantics
  @override
  Stream<UserModel?> authStateChanges() {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final session = data.session;
      final supabaseUser = session?.user;

      return supabaseUser == null
          ? null
          : UserModel.fromAuthJson(supabaseUser.toJson());
    });
  }
}
