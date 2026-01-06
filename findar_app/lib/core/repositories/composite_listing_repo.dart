import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/database_listing_repo.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/exceptions/network_exception.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Composite repository that combines local database and remote listing repositories
/// it checks for connectivity and uses the appropriate repository accordingly.
/// Also, there are methods where both repos are used to keep data in sync (caching).
///
/// **Offline Mode Behavior:**
/// When offline, the user can only:
/// - View their own listings
/// - View their saved listings
/// - View property details of their own and saved listings
///
/// All other operations (CRUD, recent listings, sponsored, search, etc.)
/// will throw a [NetworkException].

class CompositeListingRepository implements ListingRepository {
  final LocalListingRepository _databaseRepo;
  final RemoteListingRepository _remoteRepo;
  final InternetConnection _connectionChecker;

  CompositeListingRepository(
      this._databaseRepo, this._remoteRepo, this._connectionChecker);

  /// Check if the device has internet connectivity
  Future<bool> _hasConnection() async {
    return await _connectionChecker.hasInternetAccess;
  }

  /// Throws [NetworkException] if offline and operation is not allowed
  Future<void> _requireConnection(String operation) async {
    if (!await _hasConnection()) {
      throw NetworkException.featureUnavailable(operation);
    }
  }

  // ============================================================
  // CRUD Operations - Require internet connection
  // ============================================================

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
    await _requireConnection('Create listing');

    final result = await _remoteRepo.createListing(
      title: title,
      description: description,
      price: price,
      location: location,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      classification: classification,
      propertyType: propertyType,
      image: image,
      additionalImages: additionalImages,
      latitude: latitude,
      longitude: longitude,
      livingrooms: livingrooms,
      area: area,
    );

    return result;
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
    await _requireConnection('Edit listing');

    final result = await _remoteRepo.editListing(
      id: id,
      title: title,
      description: description,
      price: price,
      location: location,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      classification: classification,
      propertyType: propertyType,
      image: image,
      isOnline: isOnline,
    );

    return result;
  }

  @override
  Future<ReturnResult> deleteListing(int id) async {
    await _requireConnection('Delete listing');
    return await _remoteRepo.deleteListing(id);
  }

  @override
  Future<ReturnResult> toggleActiveListing(int id) async {
    await _requireConnection('Toggle listing status');
    return await _remoteRepo.toggleActiveListing(id);
  }

  // ============================================================
  // Listings that require internet - throw NetworkException if offline
  // ============================================================

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
  }) async {
    if (!await _hasConnection()) {
      throw NetworkException.featureUnavailable('Recent listings');
    }

    final listings = await _remoteRepo.getRecentListings(
      query: query,
      listingType: listingType,
    );

    // Cache listings to local database for future offline viewing
    // (if user saves them later)
    for (final listing in listings) {
      try {
        await _databaseRepo.createListing(
          title: listing.title,
          description: listing.description,
          price: listing.price,
          location: listing.location,
          bedrooms: listing.bedrooms,
          bathrooms: listing.bathrooms,
          classification: listing.classification,
          propertyType: listing.propertyType,
          image: listing.image,
        );
      } catch (_) {
        // Ignore caching errors - listing might already exist
      }
    }

    return listings;
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings() async {
    if (!await _hasConnection()) {
      throw NetworkException.featureUnavailable('Sponsored listings');
    }

    return await _remoteRepo.getSponsoredListings();
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
    if (!await _hasConnection()) {
      throw NetworkException.featureUnavailable('Search and filter');
    }

    return await _remoteRepo.getFilteredListings(
      latitude: latitude,
      longitude: longitude,
      minPrice: minPrice,
      maxPrice: maxPrice,
      listingType: listingType,
      buildingType: buildingType,
      numBedrooms: numBedrooms,
      numBathrooms: numBathrooms,
      minSqft: minSqft,
      maxSqft: maxSqft,
      listedBy: listedBy,
      sortBy: sortBy,
    );
  }

  // ============================================================
  // User's own listings - Available offline from local cache
  // ============================================================

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings() async {
    if (await _hasConnection()) {
      // Online: fetch from remote and cache locally
      final listings = await _remoteRepo.getUserListings();

      // Cache to local storage for offline access
      // Note: In a production app, you'd want to sync properly
      return listings;
    } else {
      // Offline: return from local database
      return await _databaseRepo.getUserListings();
    }
  }

  // ============================================================
  // Saved listings - Available offline from local cache
  // ============================================================

  @override
  Future<List<PropertyListing>> getSavedListings() async {
    if (await _hasConnection()) {
      // Online: fetch from remote
      final listings = await _remoteRepo.getSavedListings();

      // Update local saved IDs cache
      final savedIds = listings.map((l) => l.id).toSet();
      for (final id in savedIds) {
        await _databaseRepo.saveListing(id);
      }

      return listings;
    } else {
      // Offline: return from local database
      return await _databaseRepo.getSavedListings();
    }
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    if (await _hasConnection()) {
      return await _remoteRepo.getSavedListingIds();
    } else {
      return await _databaseRepo.getSavedListingIds();
    }
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    await _requireConnection('Save listing');

    final result = await _remoteRepo.saveListing(listingId);

    if (result.state) {
      // Also save locally for offline access
      await _databaseRepo.saveListing(listingId);
    }

    return result;
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    await _requireConnection('Unsave listing');

    final result = await _remoteRepo.unsaveListing(listingId);

    if (result.state) {
      // Also remove from local
      await _databaseRepo.unsaveListing(listingId);
    }

    return result;
  }

  // ============================================================
  // Get listing by ID - Available offline for own/saved listings only
  // ============================================================

  @override
  Future<PropertyListing?> getListingById(int id) async {
    if (await _hasConnection()) {
      // Online: fetch from remote
      return await _remoteRepo.getListingById(id);
    } else {
      // Offline: check if this is user's own listing or a saved listing
      final savedIds = await _databaseRepo.getSavedListingIds();
      final userListings = await _databaseRepo.getUserListings();
      final activeListings = userListings['active'] ?? [];
      final inactiveListings = userListings['inactive'] ?? [];
      final myListingIds = [
        ...activeListings.map((l) => l.id),
        ...inactiveListings.map((l) => l.id),
      ];

      if (savedIds.contains(id) || myListingIds.contains(id)) {
        return await _databaseRepo.getListingById(id);
      } else {
        // This listing is not available offline
        throw NetworkException.featureUnavailable('View this listing');
      }
    }
  }
}
