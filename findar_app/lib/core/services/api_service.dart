// TODO: Uncomment when connecting to real API
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:async';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  ApiException({required this.message, this.statusCode, this.response});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Centralized API Service
/// Handles all HTTP communication with backend
/// Currently uses mock data for testing - will be replaced with real API calls
class ApiService {
  // TODO: Replace with real backend URL when API is complete
  // static const String _baseUrl = 'http://localhost:8000/api';
  // static const Duration _timeout = Duration(seconds: 10);

  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  // TODO: Use _authToken when connecting to real API
  // ignore: unused_field
  String? _authToken;

  ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  /// Set authentication token for authorized requests
  /// TODO: Will be used when connecting to real backend API
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token on logout
  /// TODO: Will be used when connecting to real backend API
  void clearAuthToken() {
    _authToken = null;
  }

  /// Mock GET request
  /// In production, replace with actual HTTP GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // For now, return mock data based on endpoint
      return _getMockData(endpoint);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch data: ${e.toString()}');
    }
  }

  /// Mock POST request
  /// In production, replace with actual HTTP POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // For now, return mock response based on endpoint
      return _postMockData(endpoint, body);
    } catch (e) {
      throw ApiException(message: 'Failed to post data: ${e.toString()}');
    }
  }

  /// Mock PUT request
  /// In production, replace with actual HTTP PUT
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return _putMockData(endpoint, body);
    } catch (e) {
      throw ApiException(message: 'Failed to update data: ${e.toString()}');
    }
  }

  /// Mock DELETE request
  /// In production, replace with actual HTTP DELETE
  Future<void> delete(String endpoint) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      // Mock delete always succeeds
    } catch (e) {
      throw ApiException(message: 'Failed to delete data: ${e.toString()}');
    }
  }

  /// Get mock data based on endpoint
  Map<String, dynamic> _getMockData(String endpoint) {
    if (endpoint.contains('/listings/')) {
      return {
        'success': true,
        'data': [
          {
            'id': 1,
            'title': 'Beautiful Apartment in Downtown',
            'price': 50000,
            'location': 'Downtown',
            'bedrooms': 3,
            'bathrooms': 2,
            'image': 'assets/find-dar-test1.jpg',
            'description': 'Spacious apartment with modern amenities',
          },
          {
            'id': 2,
            'title': 'Cozy Studio Near Beach',
            'price': 30000,
            'location': 'Beach Area',
            'bedrooms': 1,
            'bathrooms': 1,
            'image': 'assets/find-dar-test2.jpg',
            'description': 'Perfect for couples',
          },
          {
            'id': 3,
            'title': 'Luxury Villa with Pool',
            'price': 150000,
            'location': 'Suburban',
            'bedrooms': 5,
            'bathrooms': 4,
            'image': 'assets/find-dar-test3.jpg',
            'description': 'Exclusive property with premium features',
          },
        ],
      };
    } else if (endpoint.contains('/users/')) {
      return {
        'success': true,
        'data': {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'profile_pic': 'assets/profile.png',
          'account_type': 'buyer',
          'credits': 100,
        },
      };
    }

    return {'success': true, 'data': {}};
  }

  /// Handle POST requests with mock data
  Map<String, dynamic> _postMockData(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    if (endpoint.contains('/auth/register')) {
      // Mock successful registration
      return {
        'success': true,
        'message': 'Registration successful',
        'data': {
          'id': 1,
          'email': body['email'],
          'name': body['name'],
          'phone': body['phone'] ?? '',
          'account_type': body['account_type'] ?? 'buyer',
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        },
      };
    } else if (endpoint.contains('/auth/login')) {
      // Mock successful login
      return {
        'success': true,
        'message': 'Login successful',
        'data': {
          'id': 1,
          'email': body['email'],
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 1,
            'name': 'John Doe',
            'email': body['email'],
            'phone': '+1234567890',
            'account_type': 'buyer',
          },
        },
      };
    } else if (endpoint.contains('/listings/create')) {
      // Mock successful listing creation
      return {
        'success': true,
        'message': 'Listing created successfully',
        'data': {
          'id': 4,
          'title': body['title'],
          'price': body['price'],
          'location': body['location'],
          'bedrooms': body['bedrooms'],
          'bathrooms': body['bathrooms'],
          'description': body['description'],
          'image': 'assets/find-dar-test1.jpg',
        },
      };
    }

    return {'success': true, 'message': 'Operation successful', 'data': body};
  }

  /// Handle PUT requests with mock data
  Map<String, dynamic> _putMockData(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    return {'success': true, 'message': 'Update successful', 'data': body};
  }

  /// Parse error response
  // TODO: Use when connecting to real API
  // ApiException _parseError(http.Response response) {
  //   try {
  //     final json = jsonDecode(response.body);
  //     return ApiException(
  //       message: json['message'] ?? 'An error occurred',
  //       statusCode: response.statusCode,
  //       response: response.body,
  //     );
  //   } catch (e) {
  //     return ApiException(
  //       message: 'Status ${response.statusCode}: ${response.reasonPhrase}',
  //       statusCode: response.statusCode,
  //       response: response.body,
  //     );
  //   }
  // }

  /// Close HTTP client (call on app shutdown)
  /// Currently no-op - will be used when real HTTP client is added
  void close() {
    // TODO: Uncomment when using real http.Client
    // _client.close();
  }
}
