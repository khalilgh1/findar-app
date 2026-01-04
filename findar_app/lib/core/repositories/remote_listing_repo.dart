import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/services/cloudinary_service.dart';
import 'package:findar/core/config/api_config.dart';

class RemoteListingRepository implements ListingRepository {
  final FindarApiService apiService;
  final CloudinaryService cloudinaryService;

  RemoteListingRepository(this.apiService, this.cloudinaryService);

  @override
  Future<ReturnResult> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String classification,
    required String propertyType,
    required String image,
    List<String>? additionalImages,
    double? latitude,
    double? longitude,
    int? livingrooms,
    double? area,
  }) async {
    print('🔍 Creating listing: $title');

    try {
      // Upload images to Cloudinary first (if not asset paths)
      String? mainPicUrl;
      List<String> picsUrls = [];

      if (!image.startsWith('assets/')) {
        print('📤 Uploading images to Cloudinary...');
        
        final uploadResult = await cloudinaryService.uploadListingImages(
          mainImagePath: image,
          additionalImagePaths: additionalImages,
        );

        if (!uploadResult.success) {
          return ReturnResult(
            state: false,
            message: 'Failed to upload images: ${uploadResult.error}',
          );
        }

        mainPicUrl = uploadResult.mainImageUrl;
        picsUrls = uploadResult.additionalImageUrls;
        
        print('✅ Images uploaded - Main: $mainPicUrl, Additional: ${picsUrls.length}');
      }

      // Map classification to backend values
      String listingType = classification.toLowerCase();
      if (listingType == 'for sale') listingType = 'sale';
      if (listingType == 'for rent') listingType = 'rent';

      // Map propertyType to backend values (lowercase)
      String buildingType = propertyType.toLowerCase();

      // Build the request body matching backend Post model fields
      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'price': price,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'listing_type': listingType, // 'rent' or 'sale'
        'building_type': buildingType,  // 'apartment', 'house', etc.
      };

      // Add Cloudinary URLs if available
      if (mainPicUrl != null) {
        body['main_pic'] = mainPicUrl;
      }
      if (picsUrls.isNotEmpty) {
        body['pics'] = picsUrls;
      }

      // Add optional fields if provided
      if (latitude != null) {
        body['latitude'] = latitude;
      }
      if (longitude != null) {
        body['longitude'] = longitude;
      }
      if (livingrooms != null) {
        body['livingrooms'] = livingrooms;
      }
      if (area != null) {
        body['area'] = area;
      }

      print('Request body: $body');

      final response = await apiService.post(
        ApiConfig.createListing,
        body: body,
      );

      print('Create listing response: $response');

      // If the service returned an error wrapper
      if (response is ReturnResult) {
        print('⚠️ createListing returned error: ${response.message}');
        return response;
      }

      // Success case - backend returns the created listing object
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        
        // Check if it has an 'id' field (indicates successful creation)
        if (map.containsKey('id')) {
          print('Listing created successfully with ID: ${map['id']}');
          return ReturnResult(
            state: true,
            message: 'Listing created successfully',
          );
        }
      }

      // Unexpected response shape
      print('⚠️ Unexpected response shape for createListing');
      return ReturnResult(
        state: false,
        message: 'Unexpected response from server',
      );
    } catch (e) {
      print('Error creating listing: $e');
      return ReturnResult(
        state: false,
        message: 'Failed to create listing: $e',
      );
    }
  }

  @override
  Future<ReturnResult> editListing({
    required int id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? classification,
    String? propertyType,
    String? image,
    bool? isOnline,
  }) async {
    print('🔍 Editing listing: $id');

    try {
      final body = <String, dynamic>{};

      // Only add fields that are provided
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;
      if (bedrooms != null) body['bedrooms'] = bedrooms;
      if (bathrooms != null) body['bathrooms'] = bathrooms;
      if (isOnline != null) body['active'] = isOnline;

      // Map classification to backend values
      if (classification != null) {
        String listingType = classification.toLowerCase();
        if (listingType == 'for sale') listingType = 'sale';
        if (listingType == 'for rent') listingType = 'rent';
        body['listing_type'] = listingType;
      }

      // Map propertyType to backend values
      if (propertyType != null) {
        body['building_type'] = propertyType.toLowerCase();
      }

      // Handle image
      if (image != null && !image.startsWith('assets/')) {
        body['main_pic'] = image;
      }

      print('Edit request body: $body');

      final response = await apiService.put(
        ApiConfig.editListing(id),
        body: body,
      );

      print('Edit listing response: $response');

      if (response is ReturnResult) {
        return response;
      }

      if (response is Map && response.containsKey('id')) {
        return ReturnResult(
          state: true,
          message: 'Listing updated successfully',
        );
      }

      return ReturnResult(
        state: false,
        message: 'Unexpected response from server',
      );
    } catch (e) {
      print('Error editing listing: $e');
      return ReturnResult(
        state: false,
        message: 'Failed to edit listing: $e',
      );
    }
  }

  @override
  Future<ReturnResult> deleteListing(int id) async {
    print('🔍 Deleting listing: $id');

    try {
      await apiService.delete(ApiConfig.editListing(id));

      return ReturnResult(
        state: true,
        message: 'Listing deleted successfully',
      );
    } catch (e) {
      print('Error deleting listing: $e');
      return ReturnResult(
        state: false,
        message: 'Failed to delete listing: $e',
      );
    }
  }

  Future<ReturnResult> toggleActiveListing(int id) async {
    print('🔍 Toggling active status for listing: $id');

    try {
      final response = await apiService.post(
        ApiConfig.toggleActiveListing(id),
        body: {}, // Empty body for toggle
      );

      print('📥 Toggle response: $response');

      // Check if response is already a ReturnResult (error case)
      if (response is ReturnResult) {
        return response;
      }

      // Check if response is a Map with error
      if (response is Map && response.containsKey('error')) {
        return ReturnResult(
          state: false,
          message: response['error'] ?? 'Failed to toggle listing',
        );
      }

      return ReturnResult(
        state: true,
        message: response['message'] ?? 'Listing status updated',
      );
    } catch (e) {
      print('❌ Error toggling listing: $e');
      return ReturnResult(
        state: false,
        message: 'Failed to toggle listing status: $e',
      );
    }
  }

  @override
  Future<List<PropertyListing>> getFilteredListings({
    double? latitude,
    double? longitude,
    double? minPrice,
    double? maxPrice,
    String? listingType,
    String? buildingType,
    int? numBedrooms,
    int? numBathrooms,
    double? minSqft,
    double? maxSqft,
    String? listedBy,
    String? sortBy,
  }) async {
    print('🔍 Fetching filtered listings');

    try {
      final queryParams = <String, dynamic>{};

      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (listingType != null) queryParams['listing_type'] = listingType;
      if (buildingType != null) queryParams['building_type'] = buildingType;
      if (numBedrooms != null) queryParams['num_bedrooms'] = numBedrooms.toString();
      if (numBathrooms != null) queryParams['num_bathrooms'] = numBathrooms.toString();
      if (minSqft != null) queryParams['min_sqft'] = minSqft.toString();
      if (maxSqft != null) queryParams['max_sqft'] = maxSqft.toString();
      if (listedBy != null) queryParams['listed_by'] = listedBy;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      print('Filter params: $queryParams');

      final response = await apiService.get(
        ApiConfig.advancedSearch,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      print('Filtered listings response: $response');

      if (response is List) {
        return _parseListingList(response);
      }

      return <PropertyListing>[];
    } catch (e) {
      print('Error fetching filtered listings: $e');
      return <PropertyListing>[];
    }
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings() async {
    print('🔍 Fetching user listings');

    try {
      final response = await apiService.get(ApiConfig.myListings);

      print('My listings response: $response');

      // If the service returned an error wrapper
      if (response is ReturnResult) {
        print('⚠️ getUserListings returned error: ${response.message}');
        return {'active': [], 'inactive': []};
      }

      // Backend returns { "active": [...], "inactive": [...] }
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);

        final activeList = map['active'] is List ? List.from(map['active']) : [];
        final inactiveList = map['inactive'] is List ? List.from(map['inactive']) : [];

        return {
          'active': _parseListingList(activeList),
          'inactive': _parseListingList(inactiveList),
        };
      }

      print('⚠️ Unexpected response shape for getUserListings');
      return {'active': [], 'inactive': []};
    } catch (e) {
      print('❌ Error fetching user listings: $e');
      return {'active': [], 'inactive': []};
    }
  }

  /// Helper method to parse a list of listing objects
  List<PropertyListing> _parseListingList(List rawList) {
    try {
      return rawList.map<PropertyListing>((e) {
        final data = Map<String, dynamic>.from(e as Map);

        // Map backend field names to model field names
        data['image'] = data['main_pic'] ?? data['image'] ?? '';
        data['isOnline'] = data['active'] ?? data['isOnline'] ?? true;
        data['isBoosted'] = data['boosted'] ?? data['isBoosted'] ?? false;

        if (!data.containsKey('location')) {
          data['location'] = data['city'] ?? 'Unknown';
        }

        return PropertyListing.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error parsing listing list: $e');
      return <PropertyListing>[];
    }
  }

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (listingType != null && listingType.isNotEmpty) {
        queryParams['listing_type'] = listingType;
      }
      print('🔴🔴🔴');
      print('Fetching recent listings with params: $queryParams');

      final response = await apiService.get(
        ApiConfig.recentListings,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      print('🔵🔵🔵');
      print('Response from recent listings: $response');
      print(response.runtimeType);

      // Expecting a JSON list from the backend
      if (response is List) {
        try {
          return response.map((e) {
            final data = Map<String, dynamic>.from(e as Map);

            // Map backend field names to model field names
            data['image'] = data['main_pic'] ?? '';
            data['isOnline'] = data['active'] ?? true;
            data['isBoosted'] = data['boosted'] ?? false;

            // For location, use a placeholder since backend doesn't provide it
            if (!data.containsKey('location')) {
              data['location'] = 'Unknown';
            }

            print('Parsing listing: ${data['title']}');
            return PropertyListing.fromJson(data);
          }).toList();
        } catch (e) {
          print('Error parsing listings: $e');
          return <PropertyListing>[];
        }
      }

      // If the API returned an error-shaped object, return empty list
      return <PropertyListing>[];
    } catch (e) {
      print('Error fetching recent listings: $e');
      return <PropertyListing>[];
    }
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings() async {
    print('🔍 Fetching sponsored listings');

    try {
      final response = await apiService.get(ApiConfig.sponsoredListings);

      print('📥 Sponsored listings response: $response');

      if (response is List) {
        return _parseListingList(response);
      }

      return <PropertyListing>[];
    } catch (e) {
      print('❌ Error fetching sponsored listings: $e');
      return <PropertyListing>[];
    }
  }

  @override
  Future<List<PropertyListing>> getSavedListings() async {
    print('🔍 Fetching saved listings');

    try {
      final response = await apiService.get(ApiConfig.savedListings);

      print('📥 Saved listings response: $response');

      if (response is List) {
        return _parseListingList(response);
      }

      return <PropertyListing>[];
    } catch (e) {
      print('❌ Error fetching saved listings: $e');
      return <PropertyListing>[];
    }
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    print('🔍 Fetching saved listing IDs');

    try {
      final listings = await getSavedListings();
      return listings.map((listing) => listing.id).toSet();
    } catch (e) {
      print('❌ Error fetching saved listing IDs: $e');
      return <int>{};
    }
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    print('🔍 Saving listing: $listingId');

    try {
      final response = await apiService.get(ApiConfig.saveListing(listingId));

      print('📥 Save listing response: $response');

      // Check if response is a ReturnResult with error
      if (response is ReturnResult) {
        return response;
      }

      // Check if response is a Map with error field
      if (response is Map && response.containsKey('error')) {
        return ReturnResult(
          state: false,
          message: response['error'].toString(),
        );
      }

      // Check if response is a Map with message field
      if (response is Map && response.containsKey('message')) {
        return ReturnResult(
          state: true,
          message: response['message'].toString(),
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listing saved successfully',
      );
    } catch (e) {
      print('❌ Error saving listing: $e');
      return ReturnResult(
        state: false,
        message: 'Failed to save listing: $e',
      );
    }
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    print('🔍 Unsaving listing: $listingId');

    try {
      final response = await apiService.delete(ApiConfig.saveListing(listingId));

      print('📥 Unsave listing response: $response');

      // Check if response is a ReturnResult with error
      if (response is ReturnResult) {
        return response;
      }

      // Check if response is a Map with error field
      if (response is Map && response.containsKey('error')) {
        return ReturnResult(
          state: false,
          message: response['error'].toString(),
        );
      }

      // Check if response is a Map with message field
      if (response is Map && response.containsKey('message')) {
        return ReturnResult(
          state: true,
          message: response['message'].toString(),
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listing unsaved successfully',
      );
    } catch (e) {
      print('❌ Error unsaving listing: $e');
      return ReturnResult(
        state: false,
        message: 'Failed to unsave listing: $e',
      );
    }
  }

  @override
  Future<PropertyListing?> getListingById(int id) async {
    print('🔍 Fetching listing by ID: $id');

    try {
      final response = await apiService.get(ApiConfig.getListing(id));

      print('📥 Get listing response: $response');

      if (response is Map) {
        final data = Map<String, dynamic>.from(response);
        
        // Map backend field names to model field names
        data['image'] = data['main_pic'] ?? data['image'] ?? '';
        data['isOnline'] = data['active'] ?? data['isOnline'] ?? true;
        data['isBoosted'] = data['boosted'] ?? data['isBoosted'] ?? false;

        if (!data.containsKey('location')) {
          data['location'] = data['city'] ?? 'Unknown';
        }

        return PropertyListing.fromJson(data);
      }

      return null;
    } catch (e) {
      print('❌ Error fetching listing by ID: $e');
      return null;
    }
  }
}
