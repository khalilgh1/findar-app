import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/api_service.dart';

/// Listing model for properties
class Listing {
  final int id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String? image;
  final String classification; // 'apartment', 'villa', 'house', etc.
  final String propertyType; // 'rent', 'sale'
  final DateTime createdAt;
  final bool isFavorite;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    this.image,
    required this.classification,
    required this.propertyType,
    required this.createdAt,
    this.isFavorite = false,
  });

  /// Convert from API response
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      image: json['image'] as String?,
      classification: json['classification'] as String? ?? 'apartment',
      propertyType: json['property_type'] as String? ?? 'rent',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'image': image,
      'classification': classification,
      'property_type': propertyType,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }

  /// Create a copy with modified fields
  Listing copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? image,
    String? classification,
    String? propertyType,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      image: image ?? this.image,
      classification: classification ?? this.classification,
      propertyType: propertyType ?? this.propertyType,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Repository for listings operations
/// Handles fetching, creating, and managing property listings
/// Currently uses mock data - will connect to real API when backend is complete
class ListingsRepository {
  final ApiService apiService;

  ListingsRepository({required this.apiService});

  /// Fetch all listings
  /// 
  /// Returns: ReturnResult with listings data if successful
  Future<ReturnResult> fetchListings({
    String? location,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (propertyType != null) queryParams['property_type'] = propertyType;

      // Build endpoint with query parameters
      String endpoint = '/listings/';
      if (queryParams.isNotEmpty) {
        final params = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint += '?$params';
      }

      final response = await apiService.get(endpoint);

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch listings',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listings loaded successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching listings: ${e.toString()}',
      );
    }
  }

  /// Create a new listing
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String classification,
    required String propertyType,
    String? image,
  }) async {
    try {
      // Validation
      if (title.isEmpty || title.length < 3) {
        return ReturnResult(
          state: false,
          message: 'Title must be at least 3 characters',
        );
      }
      if (description.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Description is required',
        );
      }
      if (price <= 0) {
        return ReturnResult(
          state: false,
          message: 'Price must be greater than 0',
        );
      }
      if (location.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Location is required',
        );
      }

      final response = await apiService.post(
        '/listings/create',
        body: {
          'title': title,
          'description': description,
          'price': price,
          'location': location,
          'bedrooms': bedrooms,
          'bathrooms': bathrooms,
          'classification': classification,
          'property_type': propertyType,
          'image': image,
        },
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to create listing',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listing created successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error creating listing: ${e.toString()}',
      );
    }
  }

  /// Update a listing
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> updateListing(
    int id, {
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? image,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;
      if (location != null) body['location'] = location;
      if (bedrooms != null) body['bedrooms'] = bedrooms;
      if (bathrooms != null) body['bathrooms'] = bathrooms;
      if (image != null) body['image'] = image;

      if (body.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'No fields to update',
        );
      }

      final response = await apiService.put(
        '/listings/$id',
        body: body,
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update listing',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listing updated successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error updating listing: ${e.toString()}',
      );
    }
  }

  /// Delete a listing
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> deleteListing(int id) async {
    try {
      await apiService.delete('/listings/$id');
      
      return ReturnResult(
        state: true,
        message: 'Listing deleted successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error deleting listing: ${e.toString()}',
      );
    }
  }

  /// Fetch user's listings
  /// 
  /// Returns: ReturnResult with listings data if successful
  Future<ReturnResult> fetchUserListings() async {
    try {
      final response = await apiService.get('/users/listings');

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch user listings',
        );
      }

      return ReturnResult(
        state: true,
        message: 'User listings loaded successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching user listings: ${e.toString()}',
      );
    }
  }

  /// Save a listing (add to favorites)
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> saveListing(int listingId) async {
    try {
      final response = await apiService.post(
        '/saved-listings/add',
        body: {'listing_id': listingId},
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to save listing',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listing saved successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error saving listing: ${e.toString()}',
      );
    }
  }

  /// Unsave a listing (remove from favorites)
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> unsaveListing(int listingId) async {
    try {
      await apiService.delete('/saved-listings/$listingId');
      
      return ReturnResult(
        state: true,
        message: 'Listing unsaved successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error unsaving listing: ${e.toString()}',
      );
    }
  }
}
