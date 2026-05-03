import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_app/core/network/connection_checker.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';

/// Checks connectivity once on startup and shows an offline snackbar if needed.
class OfflineStartupSnackbar extends StatefulWidget {
  /// Creates an [OfflineStartupSnackbar].
  const OfflineStartupSnackbar({
    required this.connectionChecker,
    required this.child,
    super.key,
  });

  /// The connectivity service used to determine whether the app is offline.
  final ConnectionChecker connectionChecker;

  /// The wrapped app content.
  final Widget child;

  @override
  State<OfflineStartupSnackbar> createState() => _OfflineStartupSnackbarState();
}

class _OfflineStartupSnackbarState extends State<OfflineStartupSnackbar> {
  bool _hasShownOfflineSnackbar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showOfflineSnackbarIfNeeded());
    });
  }

  Future<void> _showOfflineSnackbarIfNeeded() async {
    final isConnected = await widget.connectionChecker.isConnected;
    if (!mounted || isConnected || _hasShownOfflineSnackbar) {
      return;
    }

    _hasShownOfflineSnackbar = true;
    showSnackBar(context, 'You are offline');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
