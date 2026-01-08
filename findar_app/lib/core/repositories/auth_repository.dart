import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/services/auth_manager.dart';
import 'package:findar/core/repositories/local_user_store.dart';
import 'package:findar/core/config/api_config.dart';

/// User model for authentication
class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String? profilePic;
  final String accountType;
  final int credits;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.accountType,
    required this.credits,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePic: json['profile_pic'] ?? "",
      accountType: json['account_type'] ?? 'normal',
      credits: json['credits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
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
/// Repository for authentication operations
/// Handles user registration, login, and token management
/// Currently uses mock data - will connect to real API when backend is complete
class AuthRepository {
  final FindarApiService apiService;
  final LocalUserStore _userStore;

  // Mock storage for current user session
  User? _currentUser;

  AuthRepository({required this.apiService, LocalUserStore? userStore})
      : _userStore = userStore ?? LocalUserStore();

  /// Register a new user
  ///
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String accountType,
  }) async {
    try {
      // Validation
      if (name.isEmpty || name.length < 4) {
        return ReturnResult(
          state: false,
          message: 'Name must be at least 4 characters',
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
      if (password.isEmpty || password.length < 8) {
        return ReturnResult(
          state: false,
          message: 'Password must be at least 8 characters',
        );
      }

      final response = await apiService.post(
        '/api/auth/register',
        body: {
          'username': name,
          'email': email,
          'phone': phone,
          'password': password,
          'account_type': accountType,
        },
      );

      if (response is ReturnResult && response.state != true) {
        return ReturnResult(
          state: false,
          message: response.message ?? 'Registration failed',
        );
      }

      // Store user data
      _currentUser = User.fromJson(response['data']['user']);
      await _userStore.saveUser(_currentUser!);

      // Store tokens securely (NEW)
      await AuthManager().setTokens(
        AuthTokens(
          accessToken: response['data']['access'],
          refreshToken: response['data']['refresh'],
        ),
      );

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
        '/api/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response is ReturnResult && response.state == false) {
        return ReturnResult(
          state: false,
          message: response.message ?? 'Login failed',
        );
      }

      // Store user data
      _currentUser = User.fromJson(response['data']['user']);
      await _userStore.saveUser(_currentUser!);

      // Store tokens securely (NEW)
      await AuthManager().setTokens(
        AuthTokens(
          accessToken: response['data']['access'],
          refreshToken: response['data']['refresh'],
        ),
      );

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
      await AuthManager().clear();
      _currentUser = null;
      await _userStore.clearUser();

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

      final cached = await _userStore.loadUser();
      if (cached != null) {
        _currentUser = cached;
        return ReturnResult(
          state: true,
          message: 'Profile loaded (cached)',
        );
      }

      final response = await apiService.get('/api/users/profile');

      // Handle error response from API service
      if (response is ReturnResult) {
        return response;
      }

      // Backend returns different shapes depending on endpoint:
      // - Wrapped: { success: true, data: { ...user... } }
      // - Raw user object: { id:..., email:..., ... }
      Map<String, dynamic> userJson;
      if (response is Map<String, dynamic> && response.containsKey('success')) {
        if (response['success'] != true) {
          return ReturnResult(
            state: false,
            message: response['message'] ?? 'Failed to fetch profile',
          );
        }

        final inner = response['data'];
        if (inner is Map<String, dynamic>) {
          userJson = inner;
        } else {
          return ReturnResult(
            state: false,
            message: 'Unexpected profile response format',
          );
        }
      } else if (response is Map<String, dynamic>) {
        // Assume response is the raw serialized user
        userJson = response;
      } else {
        return ReturnResult(
          state: false,
          message: 'Failed to fetch profile',
        );
      }

      _currentUser = User.fromJson(userJson);
      await _userStore.saveUser(_currentUser!);

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
    String? email,
    String? phone,
    String? profilePic,
  }) async {
    try {
      // Validate email if provided
      if (email != null && email.isNotEmpty) {
        if (!email.contains('@')) {
          return ReturnResult(
            state: false,
            message: 'Please enter a valid email',
          );
        }
      }

      final body = <String, dynamic>{};
      if (name != null) body['username'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (profilePic != null) body['profile_pic'] = profilePic;

      if (body.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'No fields to update',
        );
      }

      final response = await apiService.put(
        ApiConfig.UpdateprofileEndpoint,
        body: body,
      );

      // Handle error response from API service
      if (response is ReturnResult) {
        return response;
      }

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Profile update failed',
        );
      }

      _currentUser = User.fromJson(response['data']);
      await _userStore.saveUser(_currentUser!);

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

  /// Load cached user without touching the network
  Future<User?> loadCachedUser() async {
    _currentUser = await _userStore.loadUser();
    return _currentUser;
  }
}
