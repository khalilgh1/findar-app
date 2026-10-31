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
/// Reads are offline-first: `onUpdate` fires with cached rows, then with
/// server data, which is written back to the cache with its server ids.
/// If the server call fails, the cache stays on screen; if nothing was
/// cached, the error is rethrown so the caller can show it.
///
/// **Offline Mode Behavior:**
/// When offline, the user can view cached recent listings, their own
/// listings, their saved listings and the details of any cached listing.
/// Writes (create/edit/delete/save/report) throw a [NetworkException].
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

  /// Maps UI filter labels onto the backend's values
  /// ('For Rent' -> 'rent', 'Real Estate Agent' -> 'agency', ...). Unknown
  /// values become null (= no filter) rather than silently matching nothing.
  static String? _apiListingType(String? value) {
    final v = value?.toLowerCase();
    if (v == null) return null;
    if (v.contains('rent')) return 'rent';
    if (v.contains('sale')) return 'sale';
    return null;
  }

  static String? _apiListedBy(String? value) {
    final v = value?.toLowerCase();
    if (v == null) return null;
    if (v.contains('agen')) return 'agency';
    if (v.contains('owner') || v.contains('individual')) return 'individual';
    return null;
  }

  Future<void> _cache(Future<void> Function() write) async {
    try {
      await write();
    } catch (e) {
      print('Error updating listing cache: $e');
    }
  }

  /// Drop all cached listings and saved ids (call on logout).
  Future<void> clearCache() => _databaseRepo.clearAll();

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
    bool isOnline = true,
  }) async {
    await _requireConnection('Create listing');

    return _remoteRepo.createListing(
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
      isOnline: isOnline,
    );
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
  }) async {
    await _requireConnection('Edit listing');

    return _remoteRepo.editListing(
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
      additionalImages: additionalImages,
      isOnline: isOnline,
    );
  }

  @override
  Future<ReturnResult> deleteListing(int id) async {
    await _requireConnection('Delete listing');
    final result = await _remoteRepo.deleteListing(id);
    if (result.state) {
      await _cache(() => _databaseRepo.deleteListing(id));
    }
    return result;
  }

  @override
  Future<ReturnResult> toggleActiveListing(int id) async {
    await _requireConnection('Toggle listing status');
    return await _remoteRepo.toggleActiveListing(id);
  }

  @override
  Future<ReturnResult> reportListing({
    required int listingId,
    required String reason,
  }) async {
    await _requireConnection('Report listing');
    return _remoteRepo.reportListing(listingId: listingId, reason: reason);
  }

  // ============================================================
  // Offline-first reads
  // ============================================================

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    final localListings = await _databaseRepo.getRecentListings(
      query: query,
      listingType: listingType,
    );

    // Only call onUpdate with local data if it's not empty
    // This prevents overwriting existing UI data with empty local cache
    if (onUpdate != null && localListings.isNotEmpty) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      if (onUpdate != null && localListings.isEmpty) {
        onUpdate(localListings);
      }
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getRecentListings(
        query: query,
        listingType: listingType,
      );
      await _cache(() => _databaseRepo.cacheListings(remoteListings));

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }
      return remoteListings;
    } catch (e) {
      print("Error fetching remote listings: $e");
      // Keep showing the cache; with nothing cached, let the cubit show
      // its error/retry state instead of spinning forever.
      if (localListings.isEmpty) rethrow;
      return localListings;
    }
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    final localListings = await _databaseRepo.getSponsoredListings();

    if (onUpdate != null && localListings.isNotEmpty) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      if (onUpdate != null && localListings.isEmpty) {
        onUpdate(localListings);
      }
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getSponsoredListings();
      await _cache(() => _databaseRepo.cacheListings(remoteListings));

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }
      return remoteListings;
    } catch (e) {
      print("Error fetching remote sponsored listings: $e");
      if (localListings.isEmpty) rethrow;
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
    listingType = _apiListingType(listingType);
    listedBy = _apiListedBy(listedBy);
    buildingType = buildingType?.toLowerCase();

    if (!await _hasConnection()) {
      // The local cache can't do radius search, so this is a best-effort
      // approximation over whatever has been cached.
      final localListings = await _databaseRepo.getFilteredListings(
        minPrice: minPrice,
        maxPrice: maxPrice,
        listingType: listingType,
        buildingType: buildingType,
        numBedrooms: numBedrooms,
        numBathrooms: numBathrooms,
        minSqft: minSqft,
        maxSqft: maxSqft,
      );
      onUpdate?.call(localListings);
      return localListings;
    }

    // Online: show only server results, so a partial local match doesn't
    // flash before the real result set.
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
    await _cache(() => _databaseRepo.cacheListings(remoteListings));

    onUpdate?.call(remoteListings);
    return remoteListings;
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings({
    OnDataUpdate<Map<String, List<PropertyListing>>>? onUpdate,
  }) async {
    final localListings = await _databaseRepo.getUserListings();

    final hasLocalData = localListings['active']?.isNotEmpty == true ||
        localListings['inactive']?.isNotEmpty == true;

    if (onUpdate != null && hasLocalData) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      if (onUpdate != null && !hasLocalData) {
        onUpdate(localListings);
      }
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getUserListings();
      await _cache(() => _databaseRepo.cacheUserListings(remoteListings));

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }
      return remoteListings;
    } catch (e) {
      print("Error fetching remote user listings: $e");
      if (!hasLocalData) rethrow;
      return localListings;
    }
  }

  @override
  Future<List<PropertyListing>> getSavedListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    final localListings = await _databaseRepo.getSavedListings();

    if (onUpdate != null && localListings.isNotEmpty) {
      onUpdate(localListings);
    }

    if (!await _hasConnection()) {
      if (onUpdate != null && localListings.isEmpty) {
        onUpdate(localListings);
      }
      return localListings;
    }

    try {
      final remoteListings = await _remoteRepo.getSavedListings();
      await _cache(() => _databaseRepo.cacheSavedListings(remoteListings));

      if (onUpdate != null) {
        onUpdate(remoteListings);
      }
      return remoteListings;
    } catch (e) {
      print("Error fetching remote saved listings: $e");
      if (localListings.isEmpty) rethrow;
      return localListings;
    }
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    if (await _hasConnection()) {
      try {
        final saved = await _remoteRepo.getSavedListings();
        await _cache(() => _databaseRepo.cacheSavedListings(saved));
        return saved.map((l) => l.id).toSet();
      } catch (e) {
        print("Error fetching saved listing ids: $e");
      }
    }
    return await _databaseRepo.getSavedListingIds();
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    await _requireConnection('Save listing');
    final result = await _remoteRepo.saveListing(listingId);
    if (result.state) {
      await _cache(() => _databaseRepo.saveListing(listingId));
    }
    return result;
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    await _requireConnection('Unsave listing');
    final result = await _remoteRepo.unsaveListing(listingId);
    if (result.state) {
      await _cache(() => _databaseRepo.unsaveListing(listingId));
    }
    return result;
  }

  // ============================================================
  // Get listing by ID - Available offline for cached listings
  // ============================================================

  @override
  Future<PropertyListing?> getListingById(int id) async {
    if (await _hasConnection()) {
      final listing = await _remoteRepo.getListingById(id);
      if (listing != null) {
        await _cache(() => _databaseRepo.cacheListings([listing]));
      }
      return listing;
    }

    final cached = await _databaseRepo.getListingById(id);
    if (cached == null) {
      throw NetworkException.featureUnavailable('This listing');
    }
    return cached;
  }
}
