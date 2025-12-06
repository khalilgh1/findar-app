import '../models/property_listing_model.dart';
import '../models/return_result.dart';

/// Abstract repository defining all possible listing operations in the app
abstract class ListingRepository {
  /// Create a new listing
  ///
  /// Returns a [ReturnResult] indicating success or failure of the operation
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

  /// Get filtered listings based on search criteria
  ///
  /// Supports filtering by location, price range, property type, building type,
  /// number of bedrooms/bathrooms, and area
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
  });

  /// Get listings created by the current user
  ///
  /// Returns both active and inactive listings
  Future<Map<String, List<PropertyListing>>> getUserListings();

  /// Get recent listings
  ///
  /// Optionally filter by [query] string and [listingType] (rent/sale)
  /// Returns up to 20 most recent active listings
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
  });

  /// Get sponsored/boosted listings
  ///
  /// Returns listings that are marked as boosted/sponsored
  Future<List<PropertyListing>> getSponsoredListings();

  /// Save a listing (add to user's favorites)
  /// Returns a [ReturnResult] indicating success or failure
  Future<ReturnResult> saveListing(int listingId);
}
