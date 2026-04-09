import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

/// Provides access to app directories used by local storage services.
// ignore: one_member_abstracts
abstract interface class AppDirectoryProvider {
  /// Returns the app documents directory.
  Future<Directory> getApplicationDocumentsDirectory();
}

/// Path-provider-based implementation of [AppDirectoryProvider].
class PathProviderAppDirectoryProvider implements AppDirectoryProvider {
  @override
  Future<Directory> getApplicationDocumentsDirectory() {
    return path_provider.getApplicationDocumentsDirectory();
  }
}
