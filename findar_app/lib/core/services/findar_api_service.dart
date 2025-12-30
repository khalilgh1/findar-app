import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:findar/core/config/api_config.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/auth_service.dart';
import 'package:findar/core/services/auth_manager.dart';

/// Base API Service for making HTTP requests
/// Handles all HTTP-level errors and response parsing
/// Automatically refreshes tokens when they expire
class FindarApiService {
  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  // ========================================
  // GET
  // ========================================
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    final url = queryParams != null
        ? ApiConfig.getUrlWithQuery(endpoint, queryParams)
        : ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🔵 GET $url');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(
              token: token ?? await _authService.getAccessToken(), // ✅ FIX
            ),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'GET',
        endpoint,
        retryCallback: () => get(
          endpoint,
          queryParams: queryParams,
        ),
      );
    } catch (e) {
      return _handleError(e, 'GET', url);
    }
  }

  // ========================================
  // POST
  // ========================================
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🟢 POST $url');
      print('📤 ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(
              token: token ?? await _authService.getAccessToken(), // ✅ FIX
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'POST',
        endpoint,
        retryCallback: () => post(endpoint, body: body),
      );
    } catch (e) {
      return _handleError(e, 'POST', url);
    }
  }

  // ========================================
  // PUT
  // ========================================
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🟡 PUT $url');
    }

    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(
              token: token ?? await _authService.getAccessToken(), // ✅ FIX
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'PUT',
        endpoint,
        retryCallback: () => put(endpoint, body: body),
      );
    } catch (e) {
      return _handleError(e, 'PUT', url);
    }
  }

  // ========================================
  // PATCH
  // ========================================
  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🟠 PATCH $url');
    }

    try {
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(
              token: token ?? await _authService.getAccessToken(), // ✅ FIX
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'PATCH',
        endpoint,
        retryCallback: () => patch(endpoint, body: body),
      );
    } catch (e) {
      return _handleError(e, 'PATCH', url);
    }
  }

  // ========================================
  // DELETE
  // ========================================
  Future<dynamic> delete(
    String endpoint, {
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🔴 DELETE $url');
    }

    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(
              token: token ?? await _authService.getAccessToken(), // ✅ FIX
            ),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'DELETE',
        endpoint,
        retryCallback: () => delete(endpoint),
      );
    } catch (e) {
      return _handleError(e, 'DELETE', url);
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

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      return _authService.getAccessToken() != null; // ✅ FIX
    }

    _isRefreshing = true;

    try {
      final refreshed = await _authService.refreshToken();
      if (!refreshed) {
        await _authService.logout();
      }
      return refreshed;
    } finally {
      _isRefreshing = false;
    }
  }

  // ========================================
  // RESPONSE HANDLING
  // ========================================
  Future<dynamic> _handleResponse(
    http.Response response,
    String method,
    String endpoint, {
    required Future<dynamic> Function() retryCallback,
  }) async {
    if (ApiConfig.enableApiLogging) {
      print('📥 $method ${response.statusCode}: ${response.body}');
    }

    // SUCCESS
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return true; // ✅ FIX
      return jsonDecode(response.body);
    }

    // 401
    if (response.statusCode == 401 && !_isAuthEndpoint(endpoint)) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return await retryCallback();
      }

      return ReturnResult(
        state: false,
        message: 'Session expired. Please login again.',
      );
    }

    return _createErrorResult(response, method);
  }

  // ========================================
  // ERRORS
  // ========================================
  ReturnResult _createErrorResult(http.Response response, String method) {
    String message;

    try {
      final body = jsonDecode(response.body);
      message = body is Map && body['detail'] != null
          ? body['detail'].toString()
          : response.body;
    } catch (_) {
      message = response.body.isNotEmpty
          ? response.body
          : 'Request failed (${response.statusCode})';
    }

    return ReturnResult(state: false, message: message);
  }

  dynamic _handleError(dynamic error, String method, String url) {
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

  void dispose() {
    _client.close();
  }
}
