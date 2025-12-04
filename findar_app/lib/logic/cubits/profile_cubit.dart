import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/services/api_service.dart';

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
    authRepository = AuthRepository(apiService: ApiService());
  }

  /// Fetch current user profile
  Future<void> fetchProfile() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await authRepository.getProfile();

      if (result.state) {
        // Get user data from repository
        final user = authRepository.getCurrentUser();

        emit({
          ...state,
          'data': user != null
              ? {
                  'id': user.id,
                  'name': user.name,
                  'email': user.email,
                  'phone': user.phone,
                  'profilePic': user.profilePic,
                  'accountType': user.accountType,
                  'credits': user.credits,
                }
              : {},
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
        'message': 'Error fetching profile: ${e.toString()}',
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
