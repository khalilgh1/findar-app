import 'dart:convert';
import 'dart:io';

import 'package:findar/data/dbhelper.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/local_user_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalListingRepository implements ListingRepository {
  final db = DatabaseHelper.instance;
  final String table = DatabaseHelper.table;

  final LocalUserStore _userStore;

  // Cached saved listing IDs
  Set<int>? _savedIdsCache;

  LocalListingRepository({LocalUserStore? userStore})
      : _userStore = userStore ?? LocalUserStore();

  Future<void> _ensureCachesLoaded() async {
    _savedIdsCache ??= await _userStore.loadSavedIds();
  }

  /// Logged-in user's id, or null when signed out.
  Future<int?> _getCurrentUserId() async {
    return (await _userStore.loadUser())?.id;
  }

  // ----------------------------------------------------------------
  // CACHE WRITES — called by CompositeListingRepository with server data
  // ----------------------------------------------------------------

  Map<String, dynamic> _toRow(PropertyListing l) => {
        'id': l.id,
        'title': l.title,
        'description': l.description,
        'price': l.price,
        'address': l.location,
        'bedrooms': l.bedrooms,
        'bathrooms': l.bathrooms,
        'livingrooms': l.livingrooms,
        'area': l.area,
        'listing_type': l.classification,
        'building_type': l.propertyType,
        'main_pic': l.image,
        'pics': l.additionalImages != null ? jsonEncode(l.additionalImages) : null,
        'active': l.isOnline ? 1 : 0,
        'boosted': l.isBoosted ? 1 : 0,
        'created_at': l.createdAt,
        'latitude': l.latitude,
        'longitude': l.longitude,
        'owner_id': l.ownerId,
      };

  Map<String, dynamic>? _ownerRow(PropertyListing l) {
    if (l.ownerId == null) return null;
    return {
      'id': l.ownerId,
      'username': l.ownerName ?? '',
      'email': l.ownerEmail,
      'phone': l.ownerPhone,
      'profile_pic': l.ownerImage,
      'account_type': l.ownerAccountType ?? 'individual',
    };
  }

  /// Upserts server listings, keeping their server ids and owners.
  Future<void> cacheListings(List<PropertyListing> listings) async {
    final owners = <int, Map<String, dynamic>>{};
    for (final l in listings) {
      final owner = _ownerRow(l);
      if (owner != null) owners[l.ownerId!] = owner;
    }
    await db.upsertListings(
      listings.map(_toRow).toList(),
      owners.values.toList(),
    );
  }

  /// Replaces the cached copy of the current user's listings, so listings
  /// deleted on the server also disappear offline.
  Future<void> cacheUserListings(Map<String, List<PropertyListing>> data) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;
    final listings = [...?data['active'], ...?data['inactive']];
    await db.deleteWhere(table, 'owner_id = ?', [userId]);
    await cacheListings(
      // The my_listings payload may lack owner details; they're ours.
      listings.map((l) => l.ownerId == null ? l.copyWith(ownerId: userId) : l).toList(),
    );
  }

  /// Caches the saved listings and remembers which ids are saved.
  Future<void> cacheSavedListings(List<PropertyListing> listings) async {
    await cacheListings(listings);
    _savedIdsCache = listings.map((l) => l.id).toSet();
    await _userStore.saveSavedIds(_savedIdsCache!);
  }

  /// Forget everything cached for the signed-out user.
  Future<void> clearAll() async {
    await db.clearAll();
    _savedIdsCache = <int>{};
    await _userStore.saveSavedIds(_savedIdsCache!);
  }

  /// Copy an image file to the app's local storage directory
  /// Returns the new local path
  Future<String> _saveImageLocally(String sourcePath) async {
    // If already a local app path, return as-is
    if (sourcePath.contains('app_flutter') ||
        sourcePath.startsWith('assets/')) {
      return sourcePath;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/listing_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}';
      final newPath = '${imagesDir.path}/$fileName';

      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(newPath);
        return newPath;
      }
    } catch (e) {
      print('Error saving image locally: $e');
    }
    return sourcePath;
  }

  /// Converts database row to include owner information from users table
  Future<Map<String, dynamic>> _enrichWithOwnerInfo(
      Map<String, dynamic> row) async {
    final enriched = Map<String, dynamic>.from(row);

    // Convert SQLite integer booleans to proper format for PropertyListing.fromJson
    // The model expects 'is_online' and 'is_boosted' as integers (0 or 1)
    enriched['is_online'] = row['active'] ?? 1;
    enriched['is_boosted'] = row['boosted'] ?? 0;

    // Parse pics JSON array if present
    if (row['pics'] != null && row['pics'] is String) {
      try {
        enriched['pics'] = jsonDecode(row['pics'] as String);
      } catch (_) {
        enriched['pics'] = <String>[];
      }
    }

    // Fetch owner information if owner_id is present
    final ownerId = row['owner_id'];
    if (ownerId != null) {
      final owner = await db.getUserById(ownerId as int);
      if (owner != null) {
        enriched['owner_id'] = owner['id'];
        enriched['owner_name'] = owner['username'];
        enriched['owner_email'] = owner['email'];
        enriched['owner_phone'] = owner['phone'];
        enriched['owner_image'] = owner['profile_pic'];
        enriched['owner_account_type'] = owner['account_type'];
      }
    }

    return enriched;
  }

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
    try {
      final ownerId = await _getCurrentUserId();

      // Map classification to backend values
      String listingType = classification.toLowerCase();
      if (listingType == 'for sale') listingType = 'sale';
      if (listingType == 'for rent') listingType = 'rent';

      // Save images locally
      final localMainImage = await _saveImageLocally(image);
      List<String>? localAdditionalImages;
      if (additionalImages != null && additionalImages.isNotEmpty) {
        localAdditionalImages = [];
        for (final img in additionalImages) {
          localAdditionalImages.add(await _saveImageLocally(img));
        }
      }

      final row = {
        "title": title,
        "description": description,
        "price": price,
        "address": location,
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "livingrooms": livingrooms,
        "area": area,
        "listing_type": listingType,
        "building_type": propertyType.toLowerCase(),
        "main_pic": localMainImage,
        "pics": localAdditionalImages != null
            ? jsonEncode(localAdditionalImages)
            : null,
        "active": isOnline ? 1 : 0,
        "boosted": 0,
        "created_at": DateTime.now().toIso8601String(),
        "latitude": latitude,
        "longitude": longitude,
        "owner_id": ownerId,
      };


      final newId = await db.insert(table, row);
      print("New listing created with ID: $newId, owner_id: $ownerId");
      return ReturnResult(state: true, message: "Listing created.");
    } catch (e) {
      print("Error creating listing: $e");
      return ReturnResult(state: false, message: e.toString());
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
    try {
      // Map classification to backend values if provided
      String? listingType;
      if (classification != null) {
        listingType = classification.toLowerCase();
        if (listingType == 'for sale') listingType = 'sale';
        if (listingType == 'for rent') listingType = 'rent';
      }

      final row = {
        "id": id,
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (price != null) "price": price,
        if (location != null) "address": location,
        if (bedrooms != null) "bedrooms": bedrooms,
        if (bathrooms != null) "bathrooms": bathrooms,
        if (listingType != null) "listing_type": listingType,
        if (propertyType != null) "building_type": propertyType.toLowerCase(),
        if (image != null) "main_pic": image,
        if (isOnline != null) "active": isOnline ? 1 : 0,
        if (area != null) "area": area,
      };

      await db.update(table, row);
      return ReturnResult(state: true, message: "Listing updated.");
    } catch (e) {
      return ReturnResult(state: false, message: e.toString());
    }
  }

  @override
  Future<ReturnResult> deleteListing(int id) async {
    try {
      await _ensureCachesLoaded();
      _savedIdsCache!.remove(id);
      await _userStore.saveSavedIds(_savedIdsCache!);

      await db.delete(table, id);
      return ReturnResult(state: true, message: "Listing deleted.");
    } catch (e) {
      return ReturnResult(state: false, message: e.toString());
    }
  }

  @override
  Future<ReturnResult> toggleActiveListing(int id) async {
    try {
      // Get the current listing
      final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
      if (results.isEmpty) {
        return ReturnResult(state: false, message: "Listing not found.");
      }

      final listing = results.first;
      // Toggle the active value (uses 'active' column now)
      final currentStatus = listing['active'] == 1;
      final newStatus = !currentStatus;

      await db.update(table, {
        'id': id,
        'active': newStatus ? 1 : 0,
      });

      return ReturnResult(
          state: true,
          message:
              "Listing status updated to ${newStatus ? 'active' : 'inactive'}.");
    } catch (e) {
      return ReturnResult(state: false, message: e.toString());
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
    String where = "active = 1";
    List<Object?> args = [];

    if (minPrice != null) {
      where += " AND price >= ?";
      args.add(minPrice);
    }

    if (maxPrice != null) {
      where += " AND price <= ?";
      args.add(maxPrice);
    }

    if (listingType != null) {
      where += " AND listing_type = ?";
      args.add(listingType.toLowerCase());
    }

    if (buildingType != null) {
      where += " AND building_type = ?";
      args.add(buildingType.toLowerCase());
    }

    if (numBedrooms != null) {
      where += " AND bedrooms >= ?";
      args.add(numBedrooms);
    }

    if (numBathrooms != null) {
      where += " AND bathrooms >= ?";
      args.add(numBathrooms);
    }

    if (minSqft != null) {
      where += " AND area >= ?";
      args.add(minSqft);
    }

    if (maxSqft != null) {
      where += " AND area <= ?";
      args.add(maxSqft);
    }

    final rows = await db.query(table, where: where, whereArgs: args);

    final listings = <PropertyListing>[];
    for (final row in rows) {
      final enriched = await _enrichWithOwnerInfo(row);
      listings.add(PropertyListing.fromJson(enriched));
    }
    return listings;
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings({
    OnDataUpdate<Map<String, List<PropertyListing>>>? onUpdate,
  }) async {
    final ownerId = await _getCurrentUserId();
    if (ownerId == null) {
      return {"active": <PropertyListing>[], "inactive": <PropertyListing>[]};
    }

    // Query listings where owner_id matches current user
    final rows = await db.query(
      table,
      where: "owner_id = ?",
      whereArgs: [ownerId],
    );

    print(
        "getUserListings: Found ${rows.length} listings for owner_id: $ownerId");

    final listings = <PropertyListing>[];
    for (final row in rows) {
      final enriched = await _enrichWithOwnerInfo(row);
      listings.add(PropertyListing.fromJson(enriched));
    }

    return {
      "active": listings.where((e) => e.isOnline).toList(),
      "inactive": listings.where((e) => !e.isOnline).toList(),
    };
  }

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    String where = "active = 1";
    List<Object?> args = [];

    if (query != null && query.isNotEmpty) {
      where += " AND title LIKE ?";
      args.add("%$query%");
    }
    if (listingType != null) {
      where += " AND listing_type = ?";
      args.add(listingType.toLowerCase());
    }

    final rows = await db.rawQuery("""
      SELECT * FROM $table 
      WHERE $where
      ORDER BY created_at DESC
      LIMIT 20
    """, args);

    final listings = <PropertyListing>[];
    for (final row in rows) {
      final enriched = await _enrichWithOwnerInfo(row);
      listings.add(PropertyListing.fromJson(enriched));
    }
    return listings;
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    final rows = await db
        .query(table, where: "boosted = ? AND active = ?", whereArgs: [1, 1]);

    final listings = <PropertyListing>[];
    for (final row in rows) {
      final enriched = await _enrichWithOwnerInfo(row);
      listings.add(PropertyListing.fromJson(enriched));
    }
    return listings;
  }

  // ----------------------------------------------------------------
  // SAVED LISTINGS — stored in SharedPreferences
  // ----------------------------------------------------------------

  @override
  Future<List<PropertyListing>> getSavedListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    await _ensureCachesLoaded();
    final savedIds = _savedIdsCache!;
    if (savedIds.isEmpty) return [];

    final placeholders = List.filled(savedIds.length, '?').join(',');
    final rows = await db.query(
      table,
      where: "id IN ($placeholders)",
      whereArgs: savedIds.toList(),
    );

    final listings = <PropertyListing>[];
    for (final row in rows) {
      final enriched = await _enrichWithOwnerInfo(row);
      listings.add(PropertyListing.fromJson(enriched));
    }
    return listings;
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    await _ensureCachesLoaded();
    return Set<int>.from(_savedIdsCache!);
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    // Check if this is the user's own listing
    final ownerId = await _getCurrentUserId();
    final listing =
        await db.query(table, where: "id = ?", whereArgs: [listingId]);
    if (listing.isNotEmpty && listing.first['owner_id'] == ownerId) {
      return ReturnResult(
          state: false, message: "You cannot save your own listing.");
    }

    await _ensureCachesLoaded();
    _savedIdsCache!.add(listingId);
    await _userStore.saveSavedIds(_savedIdsCache!);
    return ReturnResult(state: true, message: "Listing saved.");
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    await _ensureCachesLoaded();
    _savedIdsCache!.remove(listingId);
    await _userStore.saveSavedIds(_savedIdsCache!);
    return ReturnResult(state: true, message: "Listing unsaved.");
  }

  @override
  Future<ReturnResult> reportListing({
    required int listingId,
    required String reason,
  }) async {
    return ReturnResult(
      state: false,
      message: 'Reporting requires an internet connection.',
    );
  }

  @override
  Future<PropertyListing?> getListingById(int id) async {
    final rows = await db.query(table, where: "id = ?", whereArgs: [id]);
    if (rows.isNotEmpty) {
      final enriched = await _enrichWithOwnerInfo(rows.first);
      return PropertyListing.fromJson(enriched);
    }
    return null;
  }

  /// Save a user to the local database
  Future<void> saveUserToDb(Map<String, dynamic> userData) async {
    await db.insertOrUpdateUser({
      'id': userData['id'],
      'username': userData['username'] ?? userData['name'] ?? '',
      'email': userData['email'] ?? '',
      'phone': userData['phone'] ?? '',
      'profile_pic': userData['profile_pic'] ?? userData['profilePic'],
      'account_type':
          userData['account_type'] ?? userData['accountType'] ?? 'normal',
      'credits': userData['credits'] ?? 0,
    });
  }

  //a method to clear all cached listings from the local database
  Future<void> clearCachedListings() async {
    await db.clearCachedListings();
  }
}
