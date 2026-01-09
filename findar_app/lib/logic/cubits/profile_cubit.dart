import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/config/api_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/auth_repository.dart';

/// ProfileCubit handles user profile operations
/// State: {data: {}, state: 'loading|done|error', message: ''}
class ProfileCubit extends Cubit<Map<String, dynamic>> {
  late final AuthRepository authRepository;

  ProfileCubit()
      : super({
          'data': {},
          'state': 'initial',
          'message': '',
        }) {
    authRepository = AuthRepository(apiService: FindarApiService());
  }

  /// Fetch current user profile
  Future<void> fetchProfile() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // If we already have a user in memory, use it
      final inMemory = authRepository.getCurrentUser();
      if (inMemory != null) {
        emit({
          ...state,
          'data': _mapUser(inMemory),
          'state': 'done',
          'message': 'Profile loaded (in-memory)',
        });
        return;
      }

      // Try cached user first (offline support)
      final cached = await authRepository.loadCachedUser();
      if (cached != null) {
        emit({
          ...state,
          'data': _mapUser(cached),
          'state': 'done',
          'message': 'Profile loaded (cached)',
        });
        return;
      }

      final result = await authRepository.getProfile();

      if (result.state) {
        // Get user data from repository
        final user = authRepository.getCurrentUser();

        emit({
          ...state,
          'data': user != null ? _mapUser(user) : {},
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
      // On error, last attempt: try cached user to at least show something
      final cached = await authRepository.loadCachedUser();
      if (cached != null) {
        emit({
          ...state,
          'data': _mapUser(cached),
          'state': 'done',
          'message': 'Profile loaded (cached)',
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': 'Error fetching profile: ${e.toString()}',
        });
      }
    }
  }

  Map<String, dynamic> _mapUser(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'phone': user.phone,
      'profilePic': user.profilePic,
      'accountType': user.accountType,
      'credits': user.credits,
    };
  }

  /// Fetch user profile by ID (for viewing other users' profiles)
  Future<void> fetchUserById(int userId) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Use ApiConfig helper to build the endpoint
      final response = await FindarApiService().get(ApiConfig.getUserProfile(userId));

      if (response is Map && response['success'] == true) {
        final user = response['user'] ?? {};
        final listings = (response['listings'] as List?) ?? [];

        // Map listings to the shape expected by the UI (imagePath, title, price)
        final mappedListings = listings.map<Map<String, dynamic>>((listing) {
          final l = listing as Map<String, dynamic>;
          return {
            'imagePath': l['main_pic'] ?? l['image'] ?? '',
            'title': l['title'] ?? '',
            'price': l['price'] ?? 0.0,
            'id': l['id'],
          };
        }).toList();

        emit({
          ...state,
          'data': {
            'id': user['id'],
            'name': user['username'] ?? user['name'] ?? '',
            'email': user['email'] ?? '',
            'phone': user['phone'] ?? '',
            'profileImage': user['profile_pic'],
            'accountType': user['account_type'] ?? user['accountType'],
            'credits': user['credits'] ?? 0,
            'listings': mappedListings,
          },
          'state': 'done',
          'message': 'User profile loaded',
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': response['message'] ?? 'Failed to load user profile',
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error fetching user profile: ${e.toString()}',
      });
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profilePic,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await authRepository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        profilePic: profilePic,
      );

      if (result.state) {
        // Reload profile after update
        await fetchProfile();
        emit({
          ...state,
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
        'message': 'Error updating profile: ${e.toString()}',
      });
    }
  }

  /// Get user statistics (listings, saved, etc.)
  Future<void> getUserStats() async {
    try {
      // Mock statistics
      final stats = {
        'totalListings': 5,
        'activeListings': 4,
        'totalViews': 342,
        'savedListings': 12,
        'credits': 100,
        'joinDate': DateTime.now()
            .subtract(const Duration(days: 180))
            .toIso8601String(),
      };

      emit({
        ...state,
        'stats': stats,
      });
    } catch (e) {
      emit({
        ...state,
        'message': 'Error fetching stats: ${e.toString()}',
      });
    }
  }

  /// Verify email
  Future<void> verifyEmail(String email) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Mock email verification
      await Future.delayed(const Duration(milliseconds: 800));

      emit({
        ...state,
        'state': 'done',
        'message': 'Verification email sent to $email',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error verifying email: ${e.toString()}',
      });
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Validate passwords
      if (currentPassword.isEmpty) {
        emit({
          ...state,
          'state': 'error',
          'message': 'Current password is required',
        });
        return;
      }

      if (newPassword.isEmpty || newPassword.length < 6) {
        emit({
          ...state,
          'state': 'error',
          'message': 'New password must be at least 6 characters',
        });
        return;
      }

      if (newPassword != confirmPassword) {
        emit({
          ...state,
          'state': 'error',
          'message': 'Passwords do not match',
        });
        return;
      }

      // Mock password change
      await Future.delayed(const Duration(milliseconds: 800));

      emit({
        ...state,
        'state': 'done',
        'message': 'Password changed successfully',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error changing password: ${e.toString()}',
      });
    }
  }

  /// Logout user
  Future<void> logout() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await authRepository.logout();

      if (result.state) {
        emit({
          'data': {},
          'state': 'initial',
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
        'message': 'Error logging out: ${e.toString()}',
      });
    }
  }
}
