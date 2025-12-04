import '../services/api_service.dart';
import '../models/property_listing_model.dart';
import '../models/return_result.dart';

class ListingRepository {
  final ApiService apiService;
  List<PropertyListing> _cachedListings = [];

  ListingRepository({required this.apiService});

  /// Get all listings for the current user
  Future<ReturnResult> getUserListings() async {
    try {
      final response = await apiService.get('/listings/my-listings');

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch listings',
        );
      }

      // Parse listings from response
      final listingsData = response['data'] as List?;
      _cachedListings = listingsData?.map((json) => PropertyListing.fromJson(json)).toList() ?? [];

      return ReturnResult(
        state: true,
        message: 'Listings fetched successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching listings: ${e.toString()}',
      );
    }
  }

  /// Get cached listings
  List<PropertyListing> getCachedListings() {
    return List.from(_cachedListings);
  }

  /// Update a listing
  Future<ReturnResult> updateListing({
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
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;
      if (location != null) body['location'] = location;
      if (bedrooms != null) body['bedrooms'] = bedrooms;
      if (bathrooms != null) body['bathrooms'] = bathrooms;
      if (classification != null) body['classification'] = classification;
      if (propertyType != null) body['property_type'] = propertyType;
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
          message: response['message'] ?? 'Listing update failed',
        );
      }

      // Update cached listing
      final updatedListing = PropertyListing.fromJson(response['data']);
      final index = _cachedListings.indexWhere((l) => l.id == id);
      if (index != -1) {
        _cachedListings[index] = updatedListing;
      }

      return ReturnResult(
        state: true,
        message: 'Listing updated successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Listing update error: ${e.toString()}',
      );
    }
  }

  /// Delete a listing
  Future<ReturnResult> deleteListing(int id) async {
    try {
      await apiService.delete('/listings/$id');

      // Remove from cache
      _cachedListings.removeWhere((l) => l.id == id);

      return ReturnResult(
        state: true,
        message: 'Listing deleted successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Delete error: ${e.toString()}',
      );
    }
  }

  /// Toggle listing online/offline status
  Future<ReturnResult> toggleListingStatus(int id, bool isOnline) async {
    try {
      final response = await apiService.put(
        '/listings/$id/status',
        body: {'is_online': isOnline},
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to update status',
        );
      }

      // Update cached listing
      final updatedListing = PropertyListing.fromJson(response['data']);
      final index = _cachedListings.indexWhere((l) => l.id == id);
      if (index != -1) {
        _cachedListings[index] = updatedListing;
      }

      return ReturnResult(
        state: true,
        message: isOnline ? 'Listing is now online' : 'Listing is now offline',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Status update error: ${e.toString()}',
      );
    }
  }
}
