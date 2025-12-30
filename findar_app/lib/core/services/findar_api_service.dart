import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:findar/core/config/api_config.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/auth_service.dart';

/// Base API Service for making HTTP requests
/// Handles all HTTP-level errors and response parsing
/// Automatically refreshes tokens when they expire
class FindarApiService {
  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  /// GET request with automatic token refresh
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {

    print("🚀 Making GET request to $endpoint with params: $queryParams");
    final url = queryParams != null
        ? ApiConfig.getUrlWithQuery(endpoint, queryParams)
        : ApiConfig.getUrl(endpoint);
    print("🌐 Full URL: $url");
    if (ApiConfig.enableApiLogging) {
      print('🔵 GET Request: $url');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'GET',
        endpoint,
        retryCallback: () => get(
          endpoint,
          queryParams: queryParams,
          token: token,
        ),
      );
    } catch (e) {
      return _handleError(e, 'GET', url);
    }
  }

  /// POST request with automatic token refresh
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🟢 POST Request: $url');
      print('📤 Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(
            ApiConfig.requestTimeout,
            onTimeout: () => throw TimeoutException(
              'Request timed out after ${ApiConfig.requestTimeout.inSeconds}s',
            ),
          );

      return await _handleResponse(
        response,
        'POST',
        endpoint,
        retryCallback: () => post(endpoint, body: body, token: token),
      );
    } catch (e) {
      return _handleError(e, 'POST', url);
    }
  }

  /// PUT request with automatic token refresh
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🟡 PUT Request: $url');
      print('📤 Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'PUT',
        endpoint,
        retryCallback: () => put(endpoint, body: body, token: token),
      );
    } catch (e) {
      return _handleError(e, 'PUT', url);
    }
  }

  /// PATCH request with automatic token refresh
  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🟠 PATCH Request: $url');
      print('📤 Body: ${jsonEncode(body)}');
    }

    try {
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'PATCH',
        endpoint,
        retryCallback: () => patch(endpoint, body: body, token: token),
      );
    } catch (e) {
      return _handleError(e, 'PATCH', url);
    }
  }

  /// DELETE request with automatic token refresh
  Future<void> delete(
    String endpoint, {
    String? token,
  }) async {
    final url = ApiConfig.getUrl(endpoint);

    if (ApiConfig.enableApiLogging) {
      print('🔴 DELETE Request: $url');
    }

    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.requestTimeout);

      return await _handleResponse(
        response,
        'DELETE',
        endpoint,
        retryCallback: () => delete(endpoint, token: token),
      );
    } catch (e) {
      return _handleError(e, 'DELETE', url);
    }
  }

  // ========================================
  // TOKEN REFRESH LOGIC
  // ========================================

  /// Check if endpoint is an authentication endpoint
  /// ✅ NEW METHOD - Identifies endpoints that shouldn't trigger token refresh
  bool _isAuthEndpoint(String endpoint) {
    final lowerEndpoint = endpoint.toLowerCase();
    return lowerEndpoint.contains('/login') ||
        lowerEndpoint.contains('/register') ||
        lowerEndpoint.contains('/refresh') ||
        lowerEndpoint.contains('/logout') ||
        lowerEndpoint.contains('/auth/login') ||
        lowerEndpoint.contains('/auth/register');
  }

  /// Refresh the access token using the refresh token
  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      if (ApiConfig.enableApiLogging) {
        print('⚠️ Already refreshing token, waiting...');
      }
      await Future.delayed(const Duration(milliseconds: 500));
      return await _authService.getAccessToken() != null;
    }

    _isRefreshing = true;

    try {
      if (ApiConfig.enableApiLogging) {
        print('🔄 Attempting to refresh access token...');
      }

      final refreshed = await _authService.refreshTokenIfPossible();

      if (refreshed) {
        if (ApiConfig.enableApiLogging) {
          print('✅ Token refreshed successfully');
        }
        return true;
      } else {
        if (ApiConfig.enableApiLogging) {
          print('❌ Refresh token expired - logging out user');
        }

        await _authService.logout();
        return false;
      }
    } catch (e) {
      if (ApiConfig.enableApiLogging) {
        print('❌ Token refresh error: $e');
      }

      await _authService.logout();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ========================================
  // PRIVATE HELPER METHODS
  // ========================================

  /// Handle successful and error responses with automatic retry on 401
  Future<dynamic> _handleResponse(
      http.Response response, String method, String endpoint,
      {required Future<dynamic> Function() retryCallback}) async {
    if (ApiConfig.enableApiLogging) {
      print('📥 $method Response (${response.statusCode}): ${response.body}');
    }

    // SUCCESS CASES (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        print('✅ Decoded response: $decoded');
        return decoded;
      } on FormatException {
        return ReturnResult(
          state: false,
          message: 'Invalid JSON response from server',
        );
      }
    }

    // ✅ CHECK: Is this an auth endpoint?
    final isAuthEndpoint = _isAuthEndpoint(endpoint);

    // UNAUTHORIZED (401)
    if (response.statusCode == 401) {
      // ✅ For auth endpoints (login/register), don't try to refresh - just throw error
      if (isAuthEndpoint) {
        if (ApiConfig.enableApiLogging) {
          print(
              '❌ 401 on auth endpoint - invalid credentials, not session expired');
        }
        return _createErrorResult(response, method);
      }

      // ✅ For protected endpoints, try to refresh token
      if (!_isRefreshing) {
        if (ApiConfig.enableApiLogging) {
          print('🔄 Got 401 Unauthorized, attempting token refresh...');
        }

        final refreshed = await _refreshToken();

        if (refreshed) {
          if (ApiConfig.enableApiLogging) {
            print('✅ Token refreshed, retrying original request...');
          }
          return await retryCallback();
        } else {
          if (ApiConfig.enableApiLogging) {
            print('❌ Token refresh failed - session expired');
          }
          return ReturnResult(
            state: false,
            message: 'Your session has expired. Please log in again.',
          );
        }
      }
    }

    // OTHER ERROR CASES
    return _createErrorResult(response, method);
  }

  /// Create a `ReturnResult` describing the error response
  ReturnResult _createErrorResult(http.Response response, String method) {
    final statusCode = response.statusCode;
    String message;

    // Try to parse error body
    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        if (body.containsKey('detail')) {
          message = body['detail'].toString();
        } else if (body.containsKey('error')) {
          message = body['error'].toString();
        } else {
          message = _parseFieldErrors(body);
        }
      } else {
        message = body.toString();
      }
    } catch (e) {
      message = response.body.isNotEmpty
          ? response.body
          : 'Request failed with status $statusCode';
    }

    // Improve messages for common statuses
    if (statusCode >= 400 && statusCode < 500) {
      if (statusCode == 401) {
        if (!(message.toLowerCase().contains('invalid') ||
            message.toLowerCase().contains('incorrect') ||
            message.toLowerCase().contains('credentials'))) {
          message =
              'Invalid credentials. Please check your email/username and password.';
        }
      } else if (statusCode == 403) {
        message = 'Access forbidden';
      } else if (statusCode == 404) {
        message = 'Resource not found';
      } else if (statusCode == 429) {
        message = 'Too many requests. Please try again later.';
      }
    } else if (statusCode >= 500) {
      message = 'Server error. Please try again later.';
    }

    if (ApiConfig.enableApiLogging) {
      print('❌ API Error ($statusCode): $message');
    }

    return ReturnResult(
      state: false,
      message: message,
    );
  }

  /// Parse Django-style field errors into readable message
  String _parseFieldErrors(Map<String, dynamic> errors) {
    final messages = <String>[];

    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        final fieldName = _formatFieldName(key);
        messages.add('$fieldName: ${value.first}');
      } else if (value is String) {
        final fieldName = _formatFieldName(key);
        messages.add('$fieldName: $value');
      }
    });

    return messages.isNotEmpty ? messages.join('\n') : 'Validation failed';
  }

  /// Convert snake_case field names to Title Case
  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Handle exceptions during HTTP calls
  dynamic _handleError(dynamic error, String method, String url) {
    if (ApiConfig.enableApiLogging) {
      print('❌ $method Error: $error');
    }

    if (error is ReturnResult) {
      return error;
    }

    if (error is http.ClientException) {
      return ReturnResult(
        state: false,
        message: 'Connection failed. Check your internet connection.',
      );
    }

    if (error is SocketException) {
      return ReturnResult(
        state: false,
        message: 'Cannot reach server. Please check:\n'
            '• Internet connection\n'
            '• Server is running\n'
            '• Correct IP address: ${ApiConfig.baseUrl}',
      );
    }

    if (error is TimeoutException) {
      return ReturnResult(
        state: false,
        message:
            'Request timed out. The server is taking too long to respond. Please check your connection and try again.',
      );
    }

    if (error is FormatException) {
      return ReturnResult(
        state: false,
        message: 'Invalid data format received from server',
      );
    }

    // If an Api HTTP error object was returned earlier in the flow, pass it through
    return ReturnResult(
      state: false,
      message: 'Unexpected error: ${error.toString()}',
    );
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
