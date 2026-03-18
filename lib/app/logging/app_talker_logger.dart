import 'package:talker/talker.dart';
import 'package:social_network_app/core/logging/app_logger.dart';

class AppTalkerLogger implements AppLogger {
  final Talker _talker;

  AppTalkerLogger({required Talker talker}) : _talker = talker;

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
