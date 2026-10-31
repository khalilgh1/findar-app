import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:findar/core/config/api_config.dart';
import 'auth_manager.dart';

class AuthService {
  final http.Client _client;
  final AuthManager _auth = AuthManager();

  /// [client] is injectable for tests; the app uses the default.
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> getAccessToken() async {
    return _auth.accessToken;
  }

  /// REFRESH TOKEN
  /// Returns false when the server rejects the refresh token (the session is
  /// over). Network failures throw instead, so a flaky connection doesn't
  /// log the user out.
  Future<bool> refreshToken() async {
    if (_auth.refreshToken == null) return false;

    final res = await _client
        .post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.refreshEndpoint)),
          headers: ApiConfig.getHeaders(),
          body: jsonEncode({'refresh': _auth.refreshToken}),
        )
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 400 || res.statusCode == 401) return false;
    if (res.statusCode != 200) {
      throw Exception('Token refresh failed (${res.statusCode})');
    }

    final json = jsonDecode(res.body);
    await _auth.setTokens(
      AuthTokens(
        accessToken: json['access'],
        // ROTATE_REFRESH_TOKENS is on, but keep the old one if the server
        // ever stops sending a new one.
        refreshToken: json['refresh'] ?? _auth.refreshToken!,
      ),
    );
    return true;
  }

  /// Tells the backend to forget this device's push token and invalidate the
  /// refresh token. Best effort: local sign-out must not depend on the
  /// network, so failures are only logged. Does not clear local tokens.
  Future<void> logout({String? deviceToken}) async {
    final access = _auth.accessToken;
    if (access == null) return;

    try {
      await _client
          .post(
            Uri.parse(ApiConfig.getUrl(ApiConfig.logoutEndpoint)),
            headers: ApiConfig.getHeaders(token: access),
            body: jsonEncode({
              if (deviceToken != null) 'device_token': deviceToken,
              'refresh': _auth.refreshToken,
            }),
          )
          // Short: the user is waiting on the logout button.
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Backend logout failed: $e');
    }
  }

  /// SEND RESET CODE
  Future<Map<String, dynamic>> sendResetCode(String email) {
    return _postPublic(
      ApiConfig.passwordResetRequest,
      {'email': email},
      fallbackError: 'Failed to send reset code',
    );
  }

  /// CHECK RESET CODE
  Future<Map<String, dynamic>> checkResetCode(String email, String code) {
    return _postPublic(
      ApiConfig.passwordResetVerify,
      {'email': email, 'code': code},
      fallbackError: 'Invalid verification code',
    );
  }

  /// RESET PASSWORD / SET NEW PASSWORD
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) {
    return _postPublic(
      ApiConfig.passwordResetConfirm,
      {'email': email, 'code': code, 'new_password': newPassword},
      fallbackError: 'Failed to reset password',
    );
  }

  /// POSTs to an unauthenticated endpoint and throws an [Exception] carrying
  /// the server's message (e.g. "Code expired") when the call fails.
  Future<Map<String, dynamic>> _postPublic(
    String endpoint,
    Map<String, dynamic> body, {
    required String fallbackError,
  }) async {
    final res = await _client
        .post(
          Uri.parse(ApiConfig.getUrl(endpoint)),
          headers: ApiConfig.getHeaders(),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.requestTimeout);

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {}

    if (res.statusCode != 200) {
      throw Exception(json?['message']?.toString() ?? fallbackError);
    }
    return json ?? <String, dynamic>{};
  }
}
