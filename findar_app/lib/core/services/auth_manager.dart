import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;

  final StreamController<void> _sessionExpired =
      StreamController<void>.broadcast();

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null;

  /// Fires when the refresh token is rejected and the user has been signed
  /// out; the app listens to this to send the user back to the login screen.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  Future<void> init() async {
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
  }

  Future<void> setTokens(AuthTokens tokens) async {
    _accessToken = tokens.accessToken;
    _refreshToken = tokens.refreshToken;
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<void> expireSession() async {
    await clear();
    _sessionExpired.add(null);
  }
}
