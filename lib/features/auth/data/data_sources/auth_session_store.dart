import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';

/// Local store for the authenticated session.
abstract interface class AuthSessionStore {
  /// Returns the persisted auth session, or `null` when no session exists.
  Future<AuthSessionModel?> getSession();

  /// Watches the persisted auth session.
  ///
  /// The stream first emits the current stored session, then emits every later
  /// session change caused by [saveSession] or [clearSession].
  Stream<AuthSessionModel?> watchSession();

  /// Persists [session] as the current authenticated session.
  Future<void> saveSession(AuthSessionModel session);

  /// Removes the persisted authenticated session.
  Future<void> clearSession();
}

/// Secure-storage backed implementation of [AuthSessionStore].
class SecureAuthSessionStore implements AuthSessionStore {
  /// Creates a secure auth session store backed by [FlutterSecureStorage].
  SecureAuthSessionStore(this._storage);

  final FlutterSecureStorage _storage;
  final StreamController<AuthSessionModel?> _sessionController =
      StreamController<AuthSessionModel?>.broadcast();

  static const _sessionKey = 'auth_session';

  @override
  Future<AuthSessionModel?> getSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null) return null;

    return AuthSessionModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Stream<AuthSessionModel?> watchSession() async* {
    // Emit the current session, or null if signed out.
    yield await getSession();
    // Then keep listening for future session changes.
    yield* _sessionController.stream;
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
    _sessionController.add(session);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
    _sessionController.add(null);
  }
}
