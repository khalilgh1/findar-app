import 'package:findar/core/services/auth_service.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/services/notification_service.dart';

/// AuthCubit handles all authentication operations
///
/// State structure:
/// {
///   'data': User | null,          // Current logged-in user
///   'state': 'initial|loading|done|error',
///   'message': 'success or error message'
/// }
class AuthCubit extends Cubit<Map<String, dynamic>> {
  late final AuthRepository authRepository;

  AuthCubit() : super({'data': null, 'state': 'initial', 'message': ''}) {
    // Initialize repository with ApiService
    authRepository = AuthRepository(apiService: FindarApiService());
  }

  /// Attempt to hydrate from cached user on start
  Future<void> hydrateFromCache() async {
    emit({...state, 'state': 'loading', 'message': ''});
    try {
      final cached = await authRepository.loadCachedUser();
      if (cached != null) {
        emit({
          ...state,
          'data': cached,
          'state': 'done',
          'message': 'Loaded cached user'
        });
      } else {
        emit({...state, 'state': 'initial', 'message': ''});
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to load cached user: ${e.toString()}'
      });
    }
  }

  /// Register new user
  ///
  /// Validates input, calls repository, emits states
  /// - Loading state shown to UI
  /// - Success/error states with messages
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String accountType,
  }) async {
    // 1. Show loading state
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // 2. Call repository method (returns ReturnResult)
      final result = await authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        accountType: accountType,
      );

      // 3. Check result.state
      if (result.state) {
        // Success: get current user from repository
        final user = authRepository.getCurrentUser();

        await NotificationService.registerDeviceAfterLogin();
        await FirebaseMessaging.instance.subscribeToTopic(
            user!.accountType == 'agency' ? 'agency' : 'individual');

        emit({
          ...state,
          'data': user,
          'state': 'done',
          'message': result.message, // "Registration successful"
        });
      } else {
        // Failure: show error message
        emit({
          ...state,
          'state': 'error',
          'message': result.message, // Validation or API error
        });
      }
    } catch (e) {
      // 4. Handle unexpected errors
      emit({
        ...state,
        'state': 'error',
        'message': 'Registration error: ${e.toString()}',
      });
    }
  }

  /// Login user
  ///
  /// Validates email/password, calls repository, emits states
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // 1. Show loading state
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // 2. Call repository method
      final result = await authRepository.login(
        email: email,
        password: password,
      );
      // 3. Check result.state
      if (result.state) {
        // Success
        final user = authRepository.getCurrentUser();

        // Register device token for notifications after successful login
        await NotificationService.registerDeviceAfterLogin();
        await FirebaseMessaging.instance.subscribeToTopic(
            user!.accountType == 'agency' ? 'agency' : 'individual');
        emit({
          ...state,
          'data': user,
          'state': 'done',
          'message': result.message, // "Login successful"
        });
      } else {
        // Failure
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Login error: ${e.toString()}',
      });
    }
  }

  /// Logout user
  /// Clears user data and token
  Future<void> logout() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await authRepository.logout();

      if (result.state) {
        emit({
          'data': null,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Logout error: ${e.toString()}',
      });
    }
  }

  /// Get user profile
  /// Fetches current logged-in user profile
  Future<void> getProfile() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await authRepository.getProfile();

      if (result.state) {
        final user = authRepository.getCurrentUser();
        emit({
          ...state,
          'data': user,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Profile fetch error: ${e.toString()}',
      });
    }
  }

  /// Update user profile
  ///
  /// Parameters are optional - only provided fields will be updated
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profilePic,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await authRepository.updateProfile(
        name: name,
        phone: phone,
        profilePic: profilePic,
      );

      if (result.state) {
        final user = authRepository.getCurrentUser();
        emit({
          ...state,
          'data': user,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Update error: ${e.toString()}',
      });
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => state['data'] != null;

  /// Get current user data
  get currentUser => state['data'];

  /// Get current state type
  String get stateType => state['state'] as String;

  /// Get current message
  String get message => state['message'] as String;

  /// Load cached user without network and emit state accordingly.
  Future<void> loadCachedUser() async {
    emit({
      ...state,
      'state': 'loading',
      'message': '',
    });

    try {
      final cached = await authRepository.loadCachedUser();
      if (cached != null) {
        emit({
          ...state,
          'data': cached,
          'state': 'done',
          'message': 'Loaded cached user',
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': 'No cached user found',
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to load cached user: ${e.toString()}',
      });
    }
  }

  /// Update just the profile picture
  Future<void> updateProfilePicture(String profilePicUrl) async {
    await updateProfile(profilePic: profilePicUrl);
  }

  /// Clear error state (useful after showing error in snackbar)
  void clearError() {
    if (state['state'] == 'error') {
      emit({
        ...state,
        'state': 'initial',
        'message': '',
      });
    }
  }

  /// Send OTP/PIN to email for registration verification
  Future<void> sendRegisterOtp({required String email}) async {
    emit({
      ...state,
      'state': 'loading',
      'message': '',
    });

    try {
      // Call repository to send OTP
      final result = await authRepository.sendRegisterOtp(email: email);
      if (result.state) {
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to send OTP: ${e.toString()}',
      });
    }
  }

  /// Complete registration by verifying OTP

  Future<void> fetchCurrentUser() async {
    await authRepository.fetchCurrentUser();
  }

  Future<void> completeRegister({
    required dynamic data,
    required String otp,
  }) async {
    emit({
      ...state,
      'state': 'loading',
      'message': '',
    });

    try {
      // Call repository to complete registration with OTP verification
      final result = await authRepository.completeRegisterWithOtp(
        name: data.name,
        email: data.email,
        phone: data.phone,
        password: data.password,
        accountType: data.accountType,
        otp: otp,
      );

      if (result.state) {
        // Success: get current user from repository
        final user = authRepository.getCurrentUser();

        print("here 1 ");
        await NotificationService.registerDeviceAfterLogin();
        print("here 2 ");
        await FirebaseMessaging.instance.subscribeToTopic(
            user!.accountType == 'agency' ? 'agency' : 'individual');
        print("here 3 ");

        emit({
          ...state,
          'data': user,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Registration completion error: ${e.toString()}',
      });
    }
  }
}
