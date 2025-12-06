import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/api_service.dart';

/// Property model
class Property {
  final int id;
  final String title;
  final String description;
  final double price;
  final String address;
  final int bedrooms;
  final int bathrooms;
  final String sqft;
  final List<String> images;
  final String agentName;
  final String agentCompany;
  final String agentImage;
  final String? agentId;
  final bool isSaved;
  final String? propertyType;
  final String? classification;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.images,
    required this.agentName,
    required this.agentCompany,
    required this.agentImage,
    this.agentId,
    this.isSaved = false,
    this.propertyType,
    this.classification,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from API response
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      sqft: json['sqft'] as String? ?? '0 sqft',
      images: (json['images'] as List?)?.cast<String>() ?? [],
      agentName: json['agentName'] as String? ?? json['agent_name'] as String? ?? '',
      agentCompany: json['agentCompany'] as String? ?? json['agent_company'] as String? ?? '',
      agentImage: json['agentImage'] as String? ?? json['agent_image'] as String? ?? '',
      agentId: json['agentId'] as String? ?? json['agent_id'] as String?,
      isSaved: json['isSaved'] as bool? ?? json['is_saved'] as bool? ?? false,
      propertyType: json['propertyType'] as String? ?? json['property_type'] as String?,
      classification: json['classification'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sqft': sqft,
      'images': images,
      'agent_name': agentName,
      'agent_company': agentCompany,
      'agent_image': agentImage,
      'agent_id': agentId,
      'is_saved': isSaved,
      'property_type': propertyType,
      'classification': classification,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Copy with modifications
  Property copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? address,
    int? bedrooms,
    int? bathrooms,
    String? sqft,
    List<String>? images,
    String? agentName,
    String? agentCompany,
    String? agentImage,
    String? agentId,
    bool? isSaved,
    String? propertyType,
    String? classification,
    double? latitude,
    double? longitude,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      address: address ?? this.address,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      sqft: sqft ?? this.sqft,
      images: images ?? this.images,
      agentName: agentName ?? this.agentName,
      agentCompany: agentCompany ?? this.agentCompany,
      agentImage: agentImage ?? this.agentImage,
      agentId: agentId ?? this.agentId,
      isSaved: isSaved ?? this.isSaved,
      propertyType: propertyType ?? this.propertyType,
      classification: classification ?? this.classification,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Repository for property operations
/// Handles fetching property details, similar properties, and property actions
class PropertyRepository {
  final ApiService apiService;

  PropertyRepository({required this.apiService});

  /// Fetch property details by ID
  Future<Property?> getPropertyDetails(int propertyId) async {
    try {
      final response = await apiService.get('/properties/$propertyId');

      if (response['success'] != true) {
        return null;
      }

      final property = Property.fromJson(response['data']);
      return property;
    } catch (e) {
      return null;
    }
  }

  /// Get similar properties based on a property
  Future<List<Property>> getSimilarProperties(int propertyId) async {
    try {
      final response = await apiService.get('/properties/$propertyId/similar');

      if (response['success'] != true) {
        return [];
      }

      final properties = (response['data'] as List?)
              ?.map((json) => Property.fromJson(json))
              .toList() ??
          [];

      return properties;
    } catch (e) {
      return [];
    }
  }

  /// Search properties with filters
  Future<List<Property>> searchProperties({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? location,
    int? minBedrooms,
    int? maxBedrooms,
    String? propertyType,
    String? classification,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (query != null) queryParams['query'] = query;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (location != null) queryParams['location'] = location;
      if (minBedrooms != null) queryParams['min_bedrooms'] = minBedrooms.toString();
      if (maxBedrooms != null) queryParams['max_bedrooms'] = maxBedrooms.toString();
      if (propertyType != null) queryParams['property_type'] = propertyType;
      if (classification != null) queryParams['classification'] = classification;

      final response = await apiService.get('/properties/search?${Uri(queryParameters: queryParams).query}');

      if (response['success'] != true) {
        return [];
      }

      final properties = (response['data'] as List?)
              ?.map((json) => Property.fromJson(json))
              .toList() ??
          [];

      return properties;
    } catch (e) {
      return [];
    }
  }

  /// Toggle save/favorite property
  Future<ReturnResult> toggleSaveProperty(int propertyId, bool currentlySaved) async {
    try {
      final endpoint = currentlySaved 
          ? '/properties/$propertyId/unsave' 
          : '/properties/$propertyId/save';
      
      final response = await apiService.post(endpoint, body: {});

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update favorite status',
        );
      }

      return ReturnResult(
        state: true,
        message: currentlySaved ? 'Removed from favorites' : 'Added to favorites',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error updating favorite: ${e.toString()}',
      );
    }
  }

  /// Report a property
  Future<ReturnResult> reportProperty({
    required int propertyId,
    required String reason,
    String? description,
  }) async {
    try {
      if (reason.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Please provide a reason for reporting',
        );
      }

      final response = await apiService.post(
        '/properties/$propertyId/report',
        body: {
          'reason': reason,
          if (description != null) 'description': description,
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

  /// Get featured/sponsored properties
  Future<List<Property>> getFeaturedProperties() async {
    try {
      final response = await apiService.get('/properties/featured');

      if (response['success'] != true) {
        return [];
      }

      final properties = (response['data'] as List?)
              ?.map((json) => Property.fromJson(json))
              .toList() ??
          [];

      return properties;
    } catch (e) {
      return [];
    }
  }

  /// Get popular properties
  Future<List<Property>> getPopularProperties() async {
    try {
      final response = await apiService.get('/properties/popular');

      if (response['success'] != true) {
        return [];
      }

      final properties = (response['data'] as List?)
              ?.map((json) => Property.fromJson(json))
              .toList() ??
          [];

      return properties;
    } catch (e) {
      return [];
    }
  }
}
