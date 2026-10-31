import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:findar/core/config/api_config.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/auth_manager.dart';
import 'package:findar/core/services/auth_service.dart';

/// Base API Service for making HTTP requests
/// Handles all HTTP-level errors and response parsing
/// Automatically refreshes tokens when they expire
///
/// Successful calls return the decoded JSON body (or `true` for an empty
/// body); failures return a [ReturnResult] with `state == false`.
class FindarApiService {
  final http.Client _client;
  final AuthService _authService;

  /// [client] is injectable for tests; the app uses the defaults.
  FindarApiService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService(client: client);

  /// One refresh in flight at a time, shared by every service instance, so
  /// parallel 401s don't each spend (and rotate) the refresh token.
  static Future<bool>? _refreshInFlight;

  // ========================================
  // GET
  // ========================================
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) {
    final url = queryParams != null
        ? ApiConfig.getUrlWithQuery(endpoint, queryParams)
        : ApiConfig.getUrl(endpoint);

    return _send('GET', endpoint, url, token, (headers) {
      return _client.get(Uri.parse(url), headers: headers);
    });
  }

  // ========================================
  // POST
  // ========================================
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) {
    final url = ApiConfig.getUrl(endpoint);
    return _send('POST', endpoint, url, token, (headers) {
      return _client.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
    }, body: body);
  }

  // ========================================
  // PUT
  // ========================================
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) {
    final url = ApiConfig.getUrl(endpoint);
    return _send('PUT', endpoint, url, token, (headers) {
      return _client.put(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
    }, body: body);
  }

  // ========================================
  // PATCH
  // ========================================
  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) {
    final url = ApiConfig.getUrl(endpoint);
    return _send('PATCH', endpoint, url, token, (headers) {
      return _client.patch(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
    }, body: body);
  }

  // ========================================
  // DELETE
  // ========================================
  Future<dynamic> delete(
    String endpoint, {
    String? token,
  }) {
    final url = ApiConfig.getUrl(endpoint);
    return _send('DELETE', endpoint, url, token, (headers) {
      return _client.delete(Uri.parse(url), headers: headers);
    });
  }

  // ========================================
  // CORE
  // ========================================
  Future<dynamic> _send(
    String method,
    String endpoint,
    String url,
    String? token,
    Future<http.Response> Function(Map<String, String> headers) request, {
    Map<String, dynamic>? body,
  }) async {
    _log(
        '$method $url${body != null ? '\nRequest body: ${jsonEncode(body)}' : ''}');

    try {
      var response = await request(
        ApiConfig.getHeaders(
            token: token ?? await _authService.getAccessToken()),
      ).timeout(ApiConfig.requestTimeout);

      // Expired access token: refresh once and replay the request once.
      // Anonymous requests have nothing to refresh.
      if (response.statusCode == 401 &&
          token == null &&
          AuthManager().isAuthenticated &&
          !_isAuthEndpoint(endpoint)) {
        if (!await _refreshToken()) {
          return ReturnResult(
            state: false,
            message: 'Session expired. Please login again.',
          );
        }
        response = await request(
          ApiConfig.getHeaders(token: await _authService.getAccessToken()),
        ).timeout(ApiConfig.requestTimeout);
      }

      return _handleResponse(response, method);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ========================================
  // TOKEN REFRESH
  // ========================================
  bool _isAuthEndpoint(String endpoint) {
    final e = endpoint.toLowerCase();
    return e.contains('/login') ||
        e.contains('/register') ||
        e.contains('/refresh') ||
        e.contains('/logout');
  }

  /// True if a new access token was obtained. False (and the session is
  /// ended) only when the server rejected the refresh token; network errors
  /// propagate to the caller's error handling instead.
  Future<bool> _refreshToken() {
    return _refreshInFlight ??= () async {
      try {
        final refreshed = await _authService.refreshToken();
        if (!refreshed) {
          await AuthManager().expireSession();
        }
        return refreshed;
      } finally {
        _refreshInFlight = null;
      }
    }();
  }

  // ========================================
  // RESPONSE HANDLING
  // ========================================
  dynamic _handleResponse(http.Response response, String method) {
    _log('Response $method ${response.statusCode}: ${response.body}');

    // SUCCESS
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return true;
      return jsonDecode(response.body);
    }

    // REDIRECT (3xx) - http.Client should follow these automatically
    // If we reach here with 3xx, it means max redirects were exceeded
    if (response.statusCode >= 300 && response.statusCode < 400) {
      return ReturnResult(
        state: false,
        message: 'Too many redirects (${response.statusCode})',
      );
    }

    if (response.statusCode == 401) {
      return ReturnResult(
        state: false,
        message: 'Session expired. Please login again.',
      );
    }

    return ReturnResult(
      state: false,
      message: _extractErrorMessage(response),
    );
  }

  /// Turns the backend's various error shapes into one readable line:
  /// `{"detail": ..}`, `{"message": ..}`, `{"error": ..}`, DRF field errors
  /// like `{"email": ["already exists"]}`, or a bare JSON string.
  String _extractErrorMessage(http.Response response) {
    final fallback = 'Request failed (${response.statusCode})';
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      // HTML error pages (e.g. Django 404/500) are not useful to show.
      return fallback;
    }

    String? flatten(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is List) {
        return value.map(flatten).whereType<String>().join(' ');
      }
      if (value is Map) {
        for (final key in const ['detail', 'message', 'error', 'errors']) {
          if (value[key] != null) return flatten(value[key]);
        }
        return value.entries
            .map((e) => '${e.key}: ${flatten(e.value) ?? ''}')
            .join('\n');
      }
      return value.toString();
    }

    final message = flatten(body);
    return (message == null || message.trim().isEmpty) ? fallback : message;
  }

  ReturnResult _handleError(Object error) {
    if (error is SocketException) {
      return ReturnResult(
        state: false,
        message: 'Cannot reach server (${ApiConfig.baseUrl})',
      );
    }

    if (error is TimeoutException) {
      return ReturnResult(
        state: false,
        message: 'Request timed out',
      );
    }

    return ReturnResult(
      state: false,
      message: 'Unexpected error: $error',
    );
  }

  void _log(String message) {
    if (ApiConfig.enableApiLogging) debugPrint(message);
  }

  void dispose() {
    _client.close();
  }
}
