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
    bool isOnline = true,
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

        print(
            '✅ Images uploaded - Main: $mainPicUrl, Additional: ${picsUrls.length}');
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
        'building_type': buildingType, // 'apartment', 'house', etc.
        'active': isOnline,
      };

      // Add Cloudinary URLs if available
      if (mainPicUrl != null) {
        body['main_pic'] = mainPicUrl;
      }
      if (picsUrls.isNotEmpty) {
        body['pics'] = picsUrls;
      }

      // Add optional fields if provided
      if (location.isNotEmpty) {
        body['address'] = location;
      }
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
    List<String>? additionalImages,
    bool? isOnline,
    double? area,
    double? latitude,
    double? longitude,
  }) async {
    print('🔍 Editing listing: $id');

    try {
      // Images that are already URLs are kept; local file paths are uploaded.
      String? mainPicUrl;
      List<String>? picsUrls;

      if (image != null && !image.startsWith('assets/')) {
        if (_isRemote(image)) {
          mainPicUrl = image;
        } else {
          final upload = await cloudinaryService.uploadImage(image, folder: 'listings');
          if (!upload.success) {
            return ReturnResult(
              state: false,
              message: 'Failed to upload images: ${upload.error}',
            );
          }
          mainPicUrl = upload.url;
        }
      }

      if (additionalImages != null) {
        picsUrls = [];
        for (final img in additionalImages) {
          if (_isRemote(img)) {
            picsUrls.add(img);
            continue;
          }
          final upload = await cloudinaryService.uploadImage(img, folder: 'listings');
          if (!upload.success) {
            return ReturnResult(
              state: false,
              message: 'Failed to upload images: ${upload.error}',
            );
          }
          picsUrls.add(upload.url!);
        }
      }

      final body = <String, dynamic>{};

      // Only add fields that are provided
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (location != null) body['address'] = location;
      if (price != null) body['price'] = price;
      if (bedrooms != null) body['bedrooms'] = bedrooms;
      if (bathrooms != null) body['bathrooms'] = bathrooms;
      if (isOnline != null) body['active'] = isOnline;
      if (area != null) body['area'] = area;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

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

      // Handle images
      if (mainPicUrl != null) {
        body['main_pic'] = mainPicUrl;
      }
      if (picsUrls != null) {
        body['pics'] = picsUrls;
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
      final response = await apiService.delete(ApiConfig.editListing(id));
      if (response is ReturnResult) return response;

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

  @override
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
    OnDataUpdate<List<PropertyListing>>? onUpdate,
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
      if (numBedrooms != null)
        queryParams['num_bedrooms'] = numBedrooms.toString();
      if (numBathrooms != null)
        queryParams['num_bathrooms'] = numBathrooms.toString();
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

      if (response is ReturnResult) {
        throw Exception('API error: ${response.message}');
      }

      if (response is List) {
        return _parseListingList(response);
      }

      throw Exception('Unexpected API response format');
    } catch (e) {
      print('Error fetching filtered listings: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings({
    OnDataUpdate<Map<String, List<PropertyListing>>>? onUpdate,
  }) async {
    print('🔍 Fetching user listings');

    try {
      final response = await apiService.get(ApiConfig.myListings);

      print('My listings response: $response');

      // If the service returned an error wrapper, throw exception
      if (response is ReturnResult) {
        print('⚠️ getUserListings returned error: ${response.message}');
        throw Exception('API error: ${response.message}');
      }

      // Backend returns { "active": [...], "inactive": [...] }
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);

        final activeList =
            map['active'] is List ? List.from(map['active']) : [];
        final inactiveList =
            map['inactive'] is List ? List.from(map['inactive']) : [];

        return {
          'active': _parseListingList(activeList),
          'inactive': _parseListingList(inactiveList),
        };
      }

      print('⚠️ Unexpected response shape for getUserListings');
      throw Exception('Unexpected API response format');
    } catch (e) {
      print('❌ Error fetching user listings: $e');
      rethrow; // Re-throw so composite repo catches it and keeps local data
    }
  }

  static bool _isRemote(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// Maps a backend `Post` payload onto [PropertyListing]'s JSON keys.
  static PropertyListing parseListing(Map raw) {
    final data = Map<String, dynamic>.from(raw);

    // The model reads `is_online` / `is_boosted`; the API sends
    // `active` / `boosted`.
    data['is_online'] = data['active'] ?? true;
    data['is_boosted'] = data['boosted'] ?? false;
    data['main_pic'] ??= '';

    final owner = data['owner_details'];
    if (owner is Map) {
      data['owner_id'] = owner['id'];
      data['owner_name'] = owner['username'];
      data['owner_email'] = owner['email'];
      data['owner_phone'] = owner['phone'];
      data['owner_image'] = owner['profile_pic'];
      data['owner_account_type'] = owner['account_type'];
    } else if (data['owner'] is int) {
      data['owner_id'] = data['owner'];
    }

    return PropertyListing.fromJson(data);
  }

  /// Parses each listing on its own so one malformed row doesn't blank the
  /// whole list.
  List<PropertyListing> _parseListingList(List rawList) {
    final listings = <PropertyListing>[];
    for (final e in rawList) {
      try {
        listings.add(parseListing(e as Map));
      } catch (err) {
        print('❌ Skipping unparsable listing: $err');
      }
    }
    return listings;
  }

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (listingType != null && listingType.isNotEmpty) {
        queryParams['listing_type'] = listingType;
      }
      print('Fetching recent listings with params: $queryParams');

      final response = await apiService.get(
        ApiConfig.recentListings,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      // Handle API error response - throw exception so composite repo doesn't update UI with empty data
      if (response is ReturnResult) {
        print('⚠️ getRecentListings returned error: ${response.message}');
        throw Exception('API error: ${response.message}');
      }

      // Expecting a JSON list from the backend
      if (response is List) {
        return _parseListingList(response);
      }

      // If the API returned an unexpected shape, throw exception
      print('⚠️ Unexpected response shape for getRecentListings');
      throw Exception('Unexpected API response format');
    } catch (e) {
      print('Error fetching recent listings: $e');
      rethrow; // Re-throw so composite repo catches it and keeps local data
    }
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    print('🔍 Fetching sponsored listings');

    try {
      final response = await apiService.get(ApiConfig.sponsoredListings);

      print('📥 Sponsored listings response: $response');

      // Handle API error response - throw exception so composite repo doesn't update UI with empty data
      if (response is ReturnResult) {
        print('⚠️ getSponsoredListings returned error: ${response.message}');
        throw Exception('API error: ${response.message}');
      }

      if (response is List) {
        return _parseListingList(response);
      }

      // If the API returned an unexpected shape, throw exception
      print('⚠️ Unexpected response shape for getSponsoredListings');
      throw Exception('Unexpected API response format');
    } catch (e) {
      print('❌ Error fetching sponsored listings: $e');
      rethrow; // Re-throw so composite repo catches it and keeps local data
    }
  }

  @override
  Future<List<PropertyListing>> getSavedListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    print('🔍 Fetching saved listings');

    try {
      final response = await apiService.get(ApiConfig.savedListings);

      print('📥 Saved listings response: $response');

      // Handle API error response - throw exception so composite repo doesn't update UI with empty data
      if (response is ReturnResult) {
        print('⚠️ getSavedListings returned error: ${response.message}');
        throw Exception('API error: ${response.message}');
      }

      if (response is List) {
        return _parseListingList(response);
      }

      // If the API returned an unexpected shape, throw exception
      print('⚠️ Unexpected response shape for getSavedListings');
      throw Exception('Unexpected API response format');
    } catch (e) {
      print('❌ Error fetching saved listings: $e');
      rethrow; // Re-throw so composite repo catches it and keeps local data
    }
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    print('🔍 Fetching saved listing IDs');

    final listings = await getSavedListings();
    return listings.map((listing) => listing.id).toSet();
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
      final response =
          await apiService.delete(ApiConfig.saveListing(listingId));

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

    final response = await apiService.get(ApiConfig.listingDetails(id));

    if (response is ReturnResult) {
      // 404 means the listing is gone; anything else is a real failure the
      // UI should show instead of an empty page.
      if (response.message.contains('not found')) return null;
      throw Exception(response.message);
    }

    if (response is Map) {
      return parseListing(response);
    }

    return null;
  }

  @override
  Future<ReturnResult> reportListing({
    required int listingId,
    required String reason,
  }) async {
    final response = await apiService.post(
      ApiConfig.reportProperty,
      body: {'property_id': listingId, 'issue_description': reason},
    );
    if (response is ReturnResult) return response;
    return ReturnResult(state: true, message: 'Report submitted');
  }
}
