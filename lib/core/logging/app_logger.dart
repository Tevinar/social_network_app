import 'package:get_it/get_it.dart';

abstract interface class AppLogger {
  void debug(String message, [Object? data]);
  void info(String message, [Object? data]);
  void warning(String message, [Object? data]);
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Global logger accessor.
AppLogger get appLogger => GetIt.I<AppLogger>();
