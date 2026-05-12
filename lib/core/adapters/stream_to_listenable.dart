import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_app/core/logging/app_logger.dart';

/// Adapts one or more streams into a [Listenable] that notifies listeners
/// whenever any source stream emits.
class StreamToListenable extends ChangeNotifier {
  /// Creates a [StreamToListenable] from [streams].
  StreamToListenable(List<Stream<void>> streams) {
    _subscriptions = streams.map((stream) {
      return stream.asBroadcastStream().listen(
        (_) => notifyListeners(),
        onError: (Object error, StackTrace stackTrace) {
          appLogger.error(
            'StreamToListenable source stream error',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );
    }).toList();

    notifyListeners();
  }

  late final List<StreamSubscription<void>> _subscriptions;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(
        subscription.cancel().catchError((Object error, StackTrace stackTrace) {
          appLogger.error(
            'Failed to cancel StreamToListenable subscription',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    }
    super.dispose();
  }
}
