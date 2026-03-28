import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/logging/app_bloc_observer.dart';
import 'package:social_app/core/logging/app_logger.dart';

/// Installs app-wide error handlers for Flutter, platform, and BLoC errors.
///
/// This is intended to run early during startup, before dependency injection is
/// fully initialized, so unexpected bootstrap errors can still be logged.
void configureGlobalErrorHandling(AppLogger bootstrapLogger) {
  // Logs errors reported by the Flutter framework, such as build and layout failures.
  FlutterError.onError = (FlutterErrorDetails details) {
    bootstrapLogger.error(
      'Unhandled Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Logs uncaught top-level async/runtime errors outside the Flutter framework.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    bootstrapLogger.error(
      'Unhandled platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  // Global `flutter_bloc` hook used to observe all blocs and cubits in the app.
  //
  // Assigning `Bloc.observer` installs a single `BlocObserver` instance that can
  // react to lifecycle events such as bloc errors, state changes, transitions,
  // and creation/closure events.
  Bloc.observer = AppBlocObserver(logger: bootstrapLogger);
}
