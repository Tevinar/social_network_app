import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const String _supabaseUrlOverride = String.fromEnvironment(
    'SUPABASE_URL',
  );
  static const String _supabaseAnonKeyOverride = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get supabaseUrl => _supabaseUrlOverride.isNotEmpty
      ? _supabaseUrlOverride
      : dotenv.get('SUPABASE_URL');

  static String get supabaseAnonKey => _supabaseAnonKeyOverride.isNotEmpty
      ? _supabaseAnonKeyOverride
      : dotenv.get('SUPABASE_ANON_KEY');
}
