import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:findar/core/di/service_locator.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/config/api_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/auth_repository.dart';

/// ProfileCubit handles user profile operations
/// State: {data: {}, state: 'loading|done|error', message: ''}
class ProfileCubit extends Cubit<Map<String, dynamic>> {
  final AuthRepository authRepository;

  ProfileCubit({AuthRepository? authRepository})
      : authRepository = authRepository ?? getIt<AuthRepository>(),
        super({
          'data': {},
          'state': 'initial',
          'message': '',
        });

  /// Fetch current user profile: shows the cached user immediately, then
  /// refreshes it from the server (credits, picture, etc. change there).
  Future<void> fetchProfile() async {
    final cached = authRepository.getCurrentUser() ??
        await authRepository.loadCachedUser();

    if (cached != null) {
      emit({
        ...state,
        'data': _mapUser(cached),
        'state': 'done',
        'message': '',
      });
    } else {
      emit({...state, 'state': 'loading', 'message': ''});
    }

    final result = await authRepository.refreshProfile();
    final user = authRepository.getCurrentUser();
    if (result.state && user != null) {
      emit({...state, 'data': _mapUser(user), 'state': 'done', 'message': ''});
    } else if (cached == null) {
      emit({...state, 'state': 'error', 'message': result.message});
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
      final response =
          await FindarApiService().get(ApiConfig.getUserProfile(userId));

      if (response is ReturnResult) {
        emit({...state, 'state': 'error', 'message': response.message});
        return;
      }

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
            // Full models for the redesigned grid (skips unparsable rows).
            'listingModels': [
              for (final l in listings)
                if (l is Map) _tryParse(l),
            ].whereType<PropertyListing>().toList(),
          },
          'state': 'done',
          'message': 'User profile loaded',
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': (response is Map ? response['message'] : null) ??
              'Failed to load user profile',
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
        // The repository already holds the updated user from the response.
        emit({
          ...state,
          'data': _mapUser(authRepository.getCurrentUser()!),
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
        'message': 'Error updating profile: ${e.toString()}',
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

  static PropertyListing? _tryParse(Map raw) {
    try {
      return RemoteListingRepository.parseListing(raw);
    } catch (_) {
      return null;
    }
  }
}
