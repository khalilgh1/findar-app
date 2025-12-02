import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/api_service.dart';

/// User model for authentication
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profilePic;
  final String accountType; // 'buyer' or 'seller'
  final int credits;
  final String? token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.accountType,
    required this.credits,
    this.token,
  });

  /// Convert from API response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePic: json['profile_pic'] as String?,
      accountType: json['account_type'] as String? ?? 'buyer',
      credits: json['credits'] as int? ?? 0,
      token: json['token'] as String?,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_pic': profilePic,
      'account_type': accountType,
      'credits': credits,
    };
  }
}

/// Repository for authentication operations
/// Handles user registration, login, and token management
/// Currently uses mock data - will connect to real API when backend is complete
class AuthRepository {
  final ApiService apiService;
  
  // Mock storage for current user session
  User? _currentUser;

  AuthRepository({required this.apiService});

  /// Register a new user
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String nin,
    required String accountType,
  }) async {
    try {
      // Validation
      if (name.isEmpty || name.length < 2) {
        return ReturnResult(
          state: false,
          message: 'Name must be at least 2 characters',
        );
      }
      if (email.isEmpty || !email.contains('@')) {
        return ReturnResult(
          state: false,
          message: 'Please enter a valid email',
        );
      }
      if (phone.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Phone number is required',
        );
      }
      if (password.isEmpty || password.length < 6) {
        return ReturnResult(
          state: false,
          message: 'Password must be at least 6 characters',
        );
      }

      final response = await apiService.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'nin': nin,
          'account_type': accountType,
        },
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Registration failed',
        );
      }

      // Store user data
      _currentUser = User.fromJson(response['data']);
      
      // Store token for future requests
      if (_currentUser?.token != null) {
        apiService.setAuthToken(_currentUser!.token!);
      }

      return ReturnResult(
        state: true,
        message: 'Registration successful',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Registration error: ${e.toString()}',
      );
    }
  }

  /// Login user
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validation
      if (email.isEmpty || !email.contains('@')) {
        return ReturnResult(
          state: false,
          message: 'Please enter a valid email',
        );
      }
      if (password.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Password is required',
        );
      }

      final response = await apiService.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Login failed',
        );
      }

      // Store user data
      _currentUser = User.fromJson(response['data']);
      
      // Store token for future requests
      if (_currentUser?.token != null) {
        apiService.setAuthToken(_currentUser!.token!);
      }

      return ReturnResult(
        state: true,
        message: 'Login successful',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  /// Logout user
  /// Clears stored token and user data
  Future<ReturnResult> logout() async {
    try {
      apiService.clearAuthToken();
      _currentUser = null;
      
      return ReturnResult(
        state: true,
        message: 'Logout successful',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Logout error: ${e.toString()}',
      );
    }
  }

  /// Get current user profile
  /// 
  /// Returns: ReturnResult with user data if successful
  Future<ReturnResult> getProfile() async {
    try {
      // If we have user in memory, return it
      if (_currentUser != null) {
        return ReturnResult(
          state: true,
          message: 'Profile loaded',
        );
      }

      final response = await apiService.get('/users/profile');

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch profile',
        );
      }

      _currentUser = User.fromJson(response['data']);
      
      return ReturnResult(
        state: true,
        message: 'Profile loaded',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Profile fetch error: ${e.toString()}',
      );
    }
  }

  /// Update user profile
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> updateProfile({
    String? name,
    String? phone,
    String? profilePic,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (profilePic != null) body['profile_pic'] = profilePic;

      if (body.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'No fields to update',
        );
      }

      final response = await apiService.put(
        '/users/profile',
        body: body,
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Profile update failed',
        );
      }

      _currentUser = User.fromJson(response['data']);
      
      return ReturnResult(
        state: true,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Profile update error: ${e.toString()}',
      );
    }
  }

  /// Get current user (helper method)
  User? getCurrentUser() {
    return _currentUser;
  }
}
