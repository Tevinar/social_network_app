import 'package:flutter_dotenv/flutter_dotenv.dart';

/// An env.
class Env {
  static const String _supabaseUrlOverride = String.fromEnvironment(
    'SUPABASE_URL',
  );
  static const String _supabaseAnonKeyOverride = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// The supabase url.
  static String get supabaseUrl => _supabaseUrlOverride.isNotEmpty
      ? _supabaseUrlOverride
      : dotenv.get('SUPABASE_URL');

  /// The supabase anon key.
  static String get supabaseAnonKey => _supabaseAnonKeyOverride.isNotEmpty
      ? _supabaseAnonKeyOverride
      : dotenv.get('SUPABASE_ANON_KEY');
}
