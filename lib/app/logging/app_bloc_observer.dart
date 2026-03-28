import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/logging/app_logger.dart';

/// Centralized observer for `Bloc` and `Cubit` internals.
///
/// Purpose:
/// - capture unexpected bloc-level errors in a single place
/// - enrich logs with the runtime type of the failing bloc/cubit
/// - optionally trace state changes during development
///
/// This observer is intentionally not responsible for logging normal
/// business failures already modeled in the app as `Either<Failure, T>` or UI
/// error states. Those failures are expected and should continue to be handled
/// locally by repositories, blocs, and presentation states.
///
/// What it logs:
/// - [onError]: uncaught errors that escape bloc/cubit logic
/// - [onChange]: state changes in debug mode only, to keep production logs
///   focused on actionable failures
class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required AppLogger logger}) : _logger = logger;
  final AppLogger _logger;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Last-resort logging for bloc/cubit errors that were not handled locally.
    _logger.error(
      'Unhandled BLoC error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    if (kDebugMode) {
      // Useful while developing, but intentionally disabled in production to
      // avoid noisy logs for every state transition.
      _logger.debug('BLoC change in ${bloc.runtimeType}', change);
    }
    super.onChange(bloc, change);
  }
}
