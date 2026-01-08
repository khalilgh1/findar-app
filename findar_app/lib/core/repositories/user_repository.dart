import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/services/findar_api_service.dart';

/// Extended user profile with additional fields
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profilePic;
  final String accountType; // 'buyer' or 'seller'
  final int credits;
  final String? bio;
  final String? company;
  final String? location;
  final int totalListings;
  final int soldListings;
  final double rating;
  final int reviewCount;
  final DateTime? joinedAt;
  final DateTime? lastActive;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.accountType,
    required this.credits,
    this.bio,
    this.company,
    this.location,
    this.totalListings = 0,
    this.soldListings = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.joinedAt,
    this.lastActive,
  });

  /// Convert from API response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePic: json['profile_pic'] as String?,
      accountType: json['account_type'] as String? ?? 'buyer',
      credits: json['credits'] as int? ?? 0,
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      totalListings: json['total_listings'] as int? ?? json['totalListings'] as int? ?? 0,
      soldListings: json['sold_listings'] as int? ?? json['soldListings'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? json['reviewCount'] as int? ?? 0,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String)
          : json['joinedAt'] != null
              ? DateTime.tryParse(json['joinedAt'] as String)
              : null,
      lastActive: json['last_active'] != null
          ? DateTime.tryParse(json['last_active'] as String)
          : json['lastActive'] != null
              ? DateTime.tryParse(json['lastActive'] as String)
              : null,
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
      'bio': bio,
      'company': company,
      'location': location,
      'total_listings': totalListings,
      'sold_listings': soldListings,
      'rating': rating,
      'review_count': reviewCount,
      'joined_at': joinedAt?.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
    };
  }

  /// Create from User object
  factory UserProfile.fromUser(User user) {
    return UserProfile(
      id: user.id,
      name: user.username,
      email: user.email,
      phone: user.phone,
      profilePic: user.profilePic,
      accountType: user.accountType,
      credits: user.credits,
    );
  }

  /// Create copy with updated fields
  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    String? accountType,
    int? credits,
    String? bio,
    String? company,
    String? location,
    int? totalListings,
    int? soldListings,
    double? rating,
    int? reviewCount,
    DateTime? joinedAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      accountType: accountType ?? this.accountType,
      credits: credits ?? this.credits,
      bio: bio ?? this.bio,
      company: company ?? this.company,
      location: location ?? this.location,
      totalListings: totalListings ?? this.totalListings,
      soldListings: soldListings ?? this.soldListings,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

/// Repository for user profile operations
class UserRepository {
  final FindarApiService apiService;

  UserRepository({required this.apiService});

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await apiService.get('/users/$userId/profile');

      if (response['success'] != true) {
        return null;
      }

      return UserProfile.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final response = await apiService.get('/profile');

      if (response['success'] != true) {
        return null;
      }

      return UserProfile.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<ReturnResult> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? company,
    String? location,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (bio != null) body['bio'] = bio;
      if (company != null) body['company'] = company;
      if (location != null) body['location'] = location;

      if (body.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'No fields to update',
        );
      }

      final response = await apiService.put(
        '/profile',
        body: body,
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update profile',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error updating profile: ${e.toString()}',
      );
    }
  }

  /// Update profile picture
  Future<ReturnResult> updateProfilePicture(String imageUrl) async {
    try {
      final response = await apiService.put(
        '/profile/picture',
        body: {'profile_pic': imageUrl},
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update profile picture',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Profile picture updated successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error updating profile picture: ${e.toString()}',
      );
    }
  }

  /// Get user's listings count
  Future<Map<String, int>> getUserListingsCount(String userId) async {
    try {
      final response = await apiService.get('/users/$userId/listings/count');

      if (response['success'] != true) {
        return {'total': 0, 'active': 0, 'sold': 0};
      }

      final data = response['data'] as Map<String, dynamic>?;
      return {
        'total': data?['total'] as int? ?? 0,
        'active': data?['active'] as int? ?? 0,
        'sold': data?['sold'] as int? ?? 0,
      };
    } catch (e) {
      return {'total': 0, 'active': 0, 'sold': 0};
    }
  }

  /// Get user's reviews
  Future<List<Map<String, dynamic>>> getUserReviews(String userId) async {
    try {
      final response = await apiService.get('/users/$userId/reviews');

      if (response['success'] != true) {
        return [];
      }

      return (response['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Add review for user
  Future<ReturnResult> addUserReview({
    required String userId,
    required double rating,
    required String comment,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        return ReturnResult(
          state: false,
          message: 'Rating must be between 1 and 5',
        );
      }

      if (comment.isEmpty || comment.length < 10) {
        return ReturnResult(
          state: false,
          message: 'Review must be at least 10 characters',
        );
      }

      final response = await apiService.post(
        '/users/$userId/reviews',
        body: {
          'rating': rating,
          'comment': comment,
        },
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to add review',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Review added successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error adding review: ${e.toString()}',
      );
    }
  }

  /// Follow/unfollow user
  Future<ReturnResult> toggleFollowUser(String userId, bool currentlyFollowing) async {
    try {
      final endpoint = currentlyFollowing
          ? '/users/$userId/unfollow'
          : '/users/$userId/follow';

      final response = await apiService.post(endpoint, body: {});

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update follow status',
        );
      }

      return ReturnResult(
        state: true,
        message: currentlyFollowing ? 'Unfollowed user' : 'Following user',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error updating follow status: ${e.toString()}',
      );
    }
  }

  /// Report user
  Future<ReturnResult> reportUser({
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      if (reason.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Please select a reason for reporting',
        );
      }

      final response = await apiService.post(
        '/users/$userId/report',
        body: {
          'reason': reason,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to submit report',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Report submitted successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error submitting report: ${e.toString()}',
      );
    }
  }

  /// Block/unblock user
  Future<ReturnResult> toggleBlockUser(String userId, bool currentlyBlocked) async {
    try {
      final endpoint = currentlyBlocked
          ? '/users/$userId/unblock'
          : '/users/$userId/block';

      final response = await apiService.post(endpoint, body: {});

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update block status',
        );
      }

      return ReturnResult(
        state: true,
        message: currentlyBlocked ? 'User unblocked' : 'User blocked',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error updating block status: ${e.toString()}',
      );
    }
  }

  /// Search users
  Future<List<UserProfile>> searchUsers({
    String? query,
    String? accountType,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build query string
      final params = <String>[];
      params.add('page=$page');
      params.add('limit=$limit');
      if (query != null && query.isNotEmpty) params.add('q=$query');
      if (accountType != null) params.add('account_type=$accountType');
      if (location != null) params.add('location=$location');

      final queryString = params.join('&');
      final endpoint = '/users/search?$queryString';

      final response = await apiService.get(endpoint);

      if (response['success'] != true) {
        return [];
      }

      final users = (response['data'] as List?)
              ?.map((json) => UserProfile.fromJson(json))
              .toList() ??
          [];

      return users;
    } catch (e) {
      return [];
    }
  }
}