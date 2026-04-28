/// Compile-time application configuration.
///
/// Values are read from Dart environment declarations supplied with
/// `--dart-define`. For example:
///
/// ```sh
/// flutter run --dart-define=BACKEND_BASE_URL=http://localhost:3000
/// ```
///
/// These values are baked into the app at build time and are intended for
/// public environment-specific configuration, not secrets.
class Env {
  /// Base URL for the backend API.
  ///
  /// Defaults to the local Nest backend port used during development. Override
  /// this value in development, staging, or production builds with:
  ///
  /// ```sh
  /// --dart-define=BACKEND_BASE_URL=https://api.example.com
  /// ```
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
