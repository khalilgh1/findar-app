import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/services/auth_manager.dart';
import 'package:findar/core/services/auth_service.dart';
import 'package:findar/core/services/firebase_oauth_service.dart';
import 'package:findar/core/repositories/local_user_store.dart';
import 'package:findar/core/config/api_config.dart';
import 'package:findar/core/services/notification_service.dart';

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
      profilePic: json['profile_pic'],
      accountType: json['account_type'] ?? 'individual',
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
/// Handles user registration, login, logout and the current user's profile.
/// Registered as a singleton in get_it so every cubit sees the same user.
class AuthRepository {
  final FindarApiService apiService;
  final LocalUserStore _userStore;
  final AuthService _authService;

  /// Wipes per-user cached data (listings cache, saved ids) on logout or
  /// when a different account signs in.
  final Future<void> Function()? clearUserData;

  User? _currentUser;

  AuthRepository({
    required this.apiService,
    LocalUserStore? userStore,
    AuthService? authService,
    this.clearUserData,
  })  : _userStore = userStore ?? LocalUserStore(),
        _authService = authService ?? AuthService();

  /// Stores tokens + user after login/register, dropping the previous
  /// account's cached data if a different user signed in on this device.
  Future<void> _startSession(Map data) async {
    final user = User.fromJson(Map<String, dynamic>.from(data['user']));
    final previousId = await _userStore.getCurrentUserId();
    if (previousId != null && previousId != user.id) {
      await clearUserData?.call();
    }

    _currentUser = user;
    await _userStore.saveUser(user);
    await AuthManager().setTokens(
      AuthTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      ),
    );
  }

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
        ApiConfig.registerEndpoint,
        body: {
          'username': name,
          'email': email,
          'phone': phone,
          'password': password,
          'account_type': accountType,
        },
      );

      if (response is ReturnResult) {
        return ReturnResult(
          state: false,
          message: response.message,
        );
      }

      await _startSession(response['data']);

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
        ApiConfig.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );
      if (response is ReturnResult) {
        return ReturnResult(
          state: false,
          message: response.message,
        );
      }

      await _startSession(response['data']);

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

  /// Exchange a Firebase ID token (Google sign-in) for a backend session.
  Future<ReturnResult> loginWithFirebaseToken(String idToken) async {
    try {
      final response = await apiService.post(
        ApiConfig.oauthEndpoint,
        body: {'id_token': idToken, 'provider': 'google'},
      );
      if (response is ReturnResult) {
        return ReturnResult(state: false, message: response.message);
      }

      await _startSession(response['data']);
      return ReturnResult(state: true, message: 'Login successful');
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  /// Logout user
  /// Tells the backend (while the access token is still valid), drops the
  /// FCM token, then clears tokens and every piece of cached user data.
  Future<ReturnResult> logout() async {
    try {
      final deviceToken = await NotificationService.getFCMToken();
      await _authService.logout(deviceToken: deviceToken);
      await NotificationService.removeTokenOnLogout();
      await FirebaseOAuthService().signOut();

      await AuthManager().clear();
      _currentUser = null;
      await _userStore.clearUser();
      await clearUserData?.call();

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

      return await refreshProfile();
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Profile fetch error: ${e.toString()}',
      );
    }
  }

  /// Always fetches the profile from the server (credits, picture, etc. can
  /// change server-side) and updates the cache.
  Future<ReturnResult> refreshProfile() async {
    try {
      final response = await apiService.get(ApiConfig.UpdateprofileEndpoint);

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
  /// Password reset, step 1: email a verification code. Throws on failure.
  Future<void> sendResetCode(String email) =>
      _authService.sendResetCode(email.trim());

  /// Password reset, step 2: check the code. Throws on failure.
  Future<void> checkResetCode(String email, String code) =>
      _authService.checkResetCode(email.trim(), code.trim());

  /// Password reset, step 3: set the new password. Throws on failure.
  Future<void> resetPassword(String email, String code, String password) =>
      _authService.resetPassword(email.trim(), code.trim(), password);

  User? getCurrentUser() {
    return _currentUser;
  }

  /// Load cached user without touching the network
  Future<User?> loadCachedUser() async {
    _currentUser = await _userStore.loadUser();
    return _currentUser;
  }
}
