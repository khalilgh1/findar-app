import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';

/// Callback type for offline-first data updates
/// Used by cubits to receive data updates as they become available
typedef OnDataUpdate<T> = void Function(T data);

/// Abstract repository defining all possible listing operations in the app
abstract class ListingRepository {
  /// Create a new listing
  ///
  /// Returns a [ReturnResult] indicating success or failure of the operation
  /// [image] - Main image file path (will be uploaded to Cloudinary)
  /// [additionalImages] - Optional list of additional image file paths
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
  });

  /// Edit an existing listing
  ///
  /// Takes the listing [id] and updated fields
  /// Returns a [ReturnResult] indicating success or failure of the operation
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
  });

  /// Delete a listing
  ///
  /// Takes the listing [id] to delete
  /// Returns a [ReturnResult] indicating success or failure of the operation
  Future<ReturnResult> deleteListing(int id);

  /// Toggle active/inactive status of a listing
  ///
  /// Takes the listing [id] to toggle
  /// Returns a [ReturnResult] indicating success or failure of the operation
  Future<ReturnResult> toggleActiveListing(int id);

  /// Get filtered listings based on search criteria
  ///
  /// Supports filtering by location, price range, property type, building type,
  /// number of bedrooms/bathrooms, area, and sorting
  /// [onUpdate] - Optional callback for offline-first updates (called with local data first, then remote)
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
  });

  /// Get listings created by the current user
  ///
  /// Returns both active and inactive listings
  /// [onUpdate] - Optional callback for offline-first updates
  Future<Map<String, List<PropertyListing>>> getUserListings({
    OnDataUpdate<Map<String, List<PropertyListing>>>? onUpdate,
  });

  /// Get recent listings
  ///
  /// Optionally filter by [query] string and [listingType] (rent/sale)
  /// Returns up to 20 most recent active listings
  /// [onUpdate] - Optional callback for offline-first updates
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  });

  /// Get sponsored/boosted listings
  ///
  /// Returns listings that are marked as boosted/sponsored
  /// [onUpdate] - Optional callback for offline-first updates
  Future<List<PropertyListing>> getSponsoredListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  });

  /// Get saved/favorite listings for the current user
  ///
  /// Returns all listings that the user has saved/favorited
  /// [onUpdate] - Optional callback for offline-first updates
  Future<List<PropertyListing>> getSavedListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  });

  /// Get IDs of saved/favorite listings for the current user
  ///
  /// Returns set of listing IDs that are saved
  Future<Set<int>> getSavedListingIds();

  /// Save a listing (add to user's favorites)
  /// Returns a [ReturnResult] indicating success or failure
  Future<ReturnResult> saveListing(int listingId);

  /// Unsave a listing (remove from user's favorites)
  /// Returns a [ReturnResult] indicating success or failure
  Future<ReturnResult> unsaveListing(int listingId);

  //get listing by id
  Future<PropertyListing?> getListingById(int id);
}
