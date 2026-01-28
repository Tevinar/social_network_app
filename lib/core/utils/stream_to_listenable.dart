import 'dart:async';

import 'package:flutter/material.dart';

// for convert stream to listenable
class StreamToListenable extends ChangeNotifier {
  late final List<StreamSubscription> subscriptions;

  StreamToListenable(List<Stream> streams) {
    subscriptions = [];
    for (var stream in streams) {
      var subscription = stream.asBroadcastStream().listen(
        (_) => notifyListeners(),
      );
      subscriptions.add(subscription);
    }
    notifyListeners(); // To remove and see if it still works
  }

  @override
  void dispose() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
