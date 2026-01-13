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

  /// Static flag to track if initial sync has been done this session
  static bool _hasInitialSyncCompleted = false;

  CompositeListingRepository(
      this._databaseRepo, this._remoteRepo, this._connectionChecker);

  /// Check if the device has internet connectivity
  Future<bool> _hasConnection() async {
    return await _connectionChecker.hasInternetAccess;
  }

  /// Sync local database with remote data once per session
  /// Call this when the app starts (e.g., on first authenticated screen)
  Future<void> syncOncePerSession() async {
    if (_hasInitialSyncCompleted) return;

    if (!await _hasConnection()) {
      print('No connection, skipping initial sync');
      return;
    }

    try {
      print('Starting initial session sync...');

      // Fetch recent listings from remote and cache them
      final remoteListings = await _remoteRepo.getRecentListings();
      await _databaseRepo.clearCachedListings();
      for (final listing in remoteListings) {
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
        } catch (e) {
          print('Error caching listing: $e');
        }
      }

      _hasInitialSyncCompleted = true;
      print('Initial session sync completed');
    } catch (e) {
      print('Error during initial sync: $e');
    }
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
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // First, fetch from local database and call onUpdate immediately
    print("Fetching recent listings from local database repository...");
    final localListings = await _databaseRepo.getRecentListings(
      query: query,
      listingType: listingType,
    );

    // Call onUpdate with local data immediately (even if empty)
    if (onUpdate != null) {
      onUpdate(localListings);
    }

    // Then try to fetch from remote if connected
    if (await _hasConnection()) {
      print("Fetching recent listings from remote repository...");
      try {
        final remoteListings = await _remoteRepo.getRecentListings(
          query: query,
          listingType: listingType,
        );

        // Clear old cached listings and cache new ones
        await _databaseRepo.clearCachedListings();
        for (final listing in remoteListings) {
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
          } catch (e) {
            print("Error caching listing ID ${listing.id}: $e");
          }
        }

        // Call onUpdate with remote data
        if (onUpdate != null) {
          onUpdate(remoteListings);
        }

        return remoteListings;
      } catch (e) {
        print("Error fetching remote listings: $e");
        // Return local listings on error
        return localListings;
      }
    }

    // Return local listings if offline
    return localListings;
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // First, fetch from local database and call onUpdate immediately
    final localListings = await _databaseRepo.getSponsoredListings();

    // Call onUpdate with local data immediately (even if empty)
    if (onUpdate != null) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getSponsoredListings();

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }

      return remoteListings;
    } catch (e) {
      print("Error fetching remote sponsored listings: $e");
      return localListings;
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
    // First, fetch from local database and call onUpdate immediately
    final localListings = await _databaseRepo.getFilteredListings(
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

    // Call onUpdate with local data immediately (even if empty)
    if (onUpdate != null) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getFilteredListings(
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

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }

      return remoteListings;
    } catch (e) {
      print("Error fetching remote filtered listings: $e");
      return localListings;
    }
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings({
    OnDataUpdate<Map<String, List<PropertyListing>>>? onUpdate,
  }) async {
    // First, fetch from local database and call onUpdate immediately
    final localListings = await _databaseRepo.getUserListings();

    // Call onUpdate with local data immediately (even if empty)
    if (onUpdate != null) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getUserListings();

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }

      return remoteListings;
    } catch (e) {
      print("Error fetching remote user listings: $e");
      return localListings;
    }
  }

  @override
  Future<List<PropertyListing>> getSavedListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // First, fetch from local database and call onUpdate immediately
    final localListings = await _databaseRepo.getSavedListings();

    // Call onUpdate with local data immediately (even if empty)
    if (onUpdate != null) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getSavedListings();

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }

      return remoteListings;
    } catch (e) {
      print("Error fetching remote saved listings: $e");
      return localListings;
    }
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    if (await _hasConnection()) {
      return await _remoteRepo.getSavedListingIds();
    }
    return await _databaseRepo.getSavedListingIds();
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    await _requireConnection('Save listing');
    return await _remoteRepo.saveListing(listingId);
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    await _requireConnection('Unsave listing');
    final result = await _remoteRepo.unsaveListing(listingId);
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
      // Offline: fetch from local database
      return await _databaseRepo.getListingById(id);
    }
  }
}
