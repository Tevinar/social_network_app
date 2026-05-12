import 'dart:async';

import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/models/auth_session_model.dart';
import 'package:social_app/features/auth/data/session/auth_session_refresher.dart';
import 'package:social_app/features/auth/data/sources/local/auth_session_store.dart';
import 'package:social_app/features/auth/data/sources/local/current_auth_user_store.dart';

/// Coordinates access-token reuse and session refresh for authenticated API
/// calls across features.
class AuthTokenManager {
  /// Creates an [AuthTokenManager].
  AuthTokenManager({
    required AuthSessionStore authSessionStore,
    required CurrentAuthUserStore currentAuthUserStore,
    required BackendAuthSessionRefresher authSessionRefresher,
    this.refreshSkew = const Duration(seconds: 60),
  }) : _authSessionStore = authSessionStore,
       _currentAuthUserStore = currentAuthUserStore,
       _authSessionRefresher = authSessionRefresher;

  final AuthSessionStore _authSessionStore;
  final CurrentAuthUserStore _currentAuthUserStore;
  final BackendAuthSessionRefresher _authSessionRefresher;

  /// Time buffer before expiry at which an access token should be refreshed.
  final Duration refreshSkew;

  Future<AuthSessionModel>? _refreshInFlight;

  /// Returns a currently valid access token, refreshing it when it is close to
  /// expiry.
  Future<String?> getValidAccessToken() async {
    final session = await _getValidSession();
    return session?.accessToken;
  }

  /// Forces a token refresh and returns the new access token.
  /// Useful when:
  /// - token was revoked server-side and the client needs
  ///   to obtain a new one to recover.
  /// - backend considers it expired already because of clock drift
  Future<String> forceRefreshAccessToken() async {
    final session = await _refreshSession();
    return session.accessToken;
  }

  Future<AuthSessionModel?> _getValidSession() async {
    final session = await _authSessionStore.getSession();
    if (session == null) {
      return null;
    }

    if (_isExpired(session.refreshTokenExpiresAt)) {
      await _clearLocalAuthState();
      throw const UnauthorizedException(
        message: 'Refresh session has expired',
      );
    }

    if (_shouldRefreshAccessToken(session)) {
      return _refreshSession();
    }

    return session;
  }

  bool _shouldRefreshAccessToken(AuthSessionModel session) {
    return DateTime.now().isAfter(
      session.accessTokenExpiresAt.subtract(refreshSkew),
    );
  }

  bool _isExpired(DateTime value) {
    return DateTime.now().isAfter(value);
  }

  Future<AuthSessionModel> _refreshSession() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _runRefresh();
    _refreshInFlight = future;
    return future.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<AuthSessionModel> _runRefresh() async {
    try {
      return await _authSessionRefresher.refreshSession();
    } on UnauthorizedException {
      await _clearLocalAuthState();
      rethrow;
    }
  }

  Future<void> _clearLocalAuthState() async {
    await _authSessionStore.clearSession();
    await _currentAuthUserStore.clearCurrentUser();
  }
}
