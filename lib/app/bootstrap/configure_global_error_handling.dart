import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/logging/app_bloc_observer.dart';
import 'package:social_app/core/logging/app_logger.dart';

/// Installs app-wide error handlers for Flutter, platform, and BLoC errors.
///
/// This is intended to run early during startup, before dependency injection is
/// fully initialized, so unexpected bootstrap errors can still be logged.
void configureGlobalErrorHandling(AppLogger bootstrapLogger) {
  // Catches errors reported by the Flutter framework itself,
  // such as build, layout, and paint failures.
  FlutterError.onError = (FlutterErrorDetails details) {
    bootstrapLogger.error(
      'Unhandled Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Catches uncaught top-level async/runtime errors
  // that happen outside Flutter framework callbacks.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    bootstrapLogger.error(
      'Unhandled platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  // Global flutter_bloc hook for observing all blocs and cubits.
  // We use it mainly to log unexpected bloc-level errors in one place.
  Bloc.observer = AppBlocObserver(logger: bootstrapLogger);
}
