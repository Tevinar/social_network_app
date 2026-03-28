import 'package:get_it/get_it.dart';

/// A app logger.
abstract interface class AppLogger {
  /// Debug.
  void debug(String message, [Object? data]);

  /// Info.
  void info(String message, [Object? data]);

  /// Warning.
  void warning(String message, [Object? data]);

  /// Error.
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Global logger accessor.
AppLogger get appLogger => GetIt.I<AppLogger>();
