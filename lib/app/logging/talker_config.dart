import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// Creates and configures the app Talker instance.
///
/// Debug builds keep verbose logs, while release builds keep only warning and
/// error logs to reduce noise.
Talker createTalker() {
  const LogLevel minimumLogLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  return Talker(
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(
        enableColors: false,
        level: minimumLogLevel,
      ),
    ),
    settings: TalkerSettings(
      maxHistoryItems: 100,
    ),
  );
}
