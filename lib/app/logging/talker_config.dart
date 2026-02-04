import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// Creates and configures a Talker instance for logging (debug mode only).
Talker createTalker() {
  return Talker(
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        enableColors: false,
        level: LogLevel.debug,
      ),
    ),
    settings: TalkerSettings(
      enabled: kDebugMode,
      useHistory: true,
      maxHistoryItems: 100,
      useConsoleLogs: true,
    ),
  );
}
