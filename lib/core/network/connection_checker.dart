import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// A connection checker.
abstract interface class ConnectionChecker {
  /// The is connected.
  Future<bool> get isConnected;
}

/// A connection checker impl.
class ConnectionCheckerImpl implements ConnectionChecker {
  /// Creates a [ConnectionCheckerImpl].
  ConnectionCheckerImpl({required this.internetConnection});

  /// The internet connection.
  final InternetConnection internetConnection;

  @override
  /// The is connected.
  Future<bool> get isConnected async => internetConnection.hasInternetAccess;
}
