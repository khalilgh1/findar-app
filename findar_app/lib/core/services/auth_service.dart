import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  ApiException({required this.message, this.statusCode, this.response});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
}


class TokenStorage {
  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';

  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  Future<AuthTokens?> loadTokens() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);

    if (access != null && refresh != null) {
      return AuthTokens(accessToken: access, refreshToken: refresh);
    }
    return null;
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}


class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  final TokenStorage _storage = TokenStorage();

  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<void> init() async {
    final tokens = await _storage.loadTokens();
    if (tokens != null) {
      _accessToken = tokens.accessToken;
      _refreshToken = tokens.refreshToken;
    }
  }

  Future<void> setTokens(AuthTokens tokens) async {
    _accessToken = tokens.accessToken;
    _refreshToken = tokens.refreshToken;
    await _storage.saveTokens(tokens);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.clear();
  }

}

// Temporary stub until AuthService is implemented
class AuthService {
  Future<String?> getAccessToken() async => null;
  Future<bool> refreshTokenIfPossible() async => false;
  Future<void> logout() async {}
}



/// Custom exception for API errors





class ApiService {
  static const String _baseUrl = 'http://192.168.1.42:8000/api';
  static const Duration _timeout = Duration(seconds: 10);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal();

  final http.Client _client = http.Client();
  final AuthManager _auth = AuthManager();

  // =========================
  // CORE REQUEST HANDLER
  // =========================
  Future<http.Response> _sendRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool retryOnAuthFail = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    final headers = {
      'Content-Type': 'application/json',
      if (_auth.accessToken != null)
        'Authorization': 'Bearer ${_auth.accessToken}',
    };

    http.Response response;

    switch (method) {
      case 'GET':
        response = await _client
            .get(uri, headers: headers)
            .timeout(_timeout);
        break;

      case 'POST':
        response = await _client
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(_timeout);
        break;

      case 'PUT':
        response = await _client
            .put(uri, headers: headers, body: jsonEncode(body))
            .timeout(_timeout);
        break;

      case 'DELETE':
        response = await _client
            .delete(uri, headers: headers)
            .timeout(_timeout);
        break;

      default:
        throw ApiException(message: 'Unsupported HTTP method');
    }

    // Access token expired
    if (response.statusCode == 401 &&
        retryOnAuthFail &&
        _auth.refreshToken != null) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return _sendRequest(
          method,
          endpoint,
          body: body,
          retryOnAuthFail: false,
        );
      } else {
        await _auth.clear();
        throw ApiException(message: 'Session expired. Please login again.');
      }
    }

    return response;
  }

  // =========================
  // TOKEN REFRESH
  // =========================

  Future<bool> _refreshToken() async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh': _auth.refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        await _auth.setTokens(
          AuthTokens(
            accessToken: json['access'],
            refreshToken: json['refresh'],
          ),
        );
        return true;
      }
    } catch (_) {}

    return false;
  }


  // =========================
  // HELPERS
  // =========================
  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw ApiException(
      message: 'API Error',
      statusCode: response.statusCode,
      response: response.body,
    );
  }

  void close() {
    _client.close();
  }
}
