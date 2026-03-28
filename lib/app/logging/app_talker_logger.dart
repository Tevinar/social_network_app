import 'package:social_app/core/logging/app_logger.dart';
import 'package:talker/talker.dart';

/// A app talker logger.
class AppTalkerLogger implements AppLogger {
  /// Creates a [AppTalkerLogger].
  AppTalkerLogger({required Talker talker}) : _talker = talker;
  final Talker _talker;

  @override
  void debug(String message, [Object? data]) {
    _talker.debug(message, data);
  }

  @override
  void info(String message, [Object? data]) {
    _talker.info(message, data);
  }

  @override
  void warning(String message, [Object? data]) {
    _talker.warning(message, data);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.error(message, error, stackTrace);
  }
}
