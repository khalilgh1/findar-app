import 'package:findar/data/dbhelper.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/local_user_store.dart';

class LocalListingRepository implements ListingRepository {
  final db = DatabaseHelper.instance;
  final String table = DatabaseHelper.table;

  final LocalUserStore _userStore;

  // Dummy in-memory saved listing IDs
  // kahlil thala fiha
  Set<int>? _savedIdsCache;
  Set<int>? _myListingIdsCache;

  LocalListingRepository({LocalUserStore? userStore})
      : _userStore = userStore ?? LocalUserStore();

  Future<void> _ensureCachesLoaded() async {
    _savedIdsCache ??= await _userStore.loadSavedIds();
    _myListingIdsCache ??= await _userStore.loadMyListingIds();
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
    double? latitude,
    double? longitude,
    int? livingrooms,
    double? area,
  }) async {
    try {
      final row = {
        "title": title,
        "description": description,
        "price": price,
        "location": location,
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "classification": classification,
        "property_type": propertyType,
        "image": image,
        "is_online": 1,
        "is_boosted": 0,
        "created_at": DateTime.now().toIso8601String(),
      };

      final newId = await db.insert(table, row);

      await _ensureCachesLoaded();
      _myListingIdsCache!.add(newId);
      await _userStore.saveMyListingIds(_myListingIdsCache!);
      return ReturnResult(state: true, message: "Listing created.");
    } catch (e) {
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
    bool? isOnline,
  }) async {
    try {
      final row = {
        "id": id,
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (price != null) "price": price,
        if (location != null) "location": location,
        if (bedrooms != null) "bedrooms": bedrooms,
        if (bathrooms != null) "bathrooms": bathrooms,
        if (classification != null) "classification": classification,
        if (propertyType != null) "property_type": propertyType,
        if (image != null) "image": image,
        if (isOnline != null) "is_online": isOnline ? 1 : 0,
        "updated_at": DateTime.now().toIso8601String(),
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
      _myListingIdsCache!.remove(id);
      _savedIdsCache!.remove(id);
      await _userStore.saveMyListingIds(_myListingIdsCache!);
      await _userStore.saveSavedIds(_savedIdsCache!);

      await db.delete(table, id);
      return ReturnResult(state: true, message: "Listing deleted.");
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
  }) async {
    String where = "1=1";
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
      where += " AND classification = ?";
      args.add(listingType);
    }

    if (buildingType != null) {
      where += " AND property_type = ?";
      args.add(buildingType);
    }

    if (numBedrooms != null) {
      where += " AND bedrooms >= ?";
      args.add(numBedrooms);
    }

    if (numBathrooms != null) {
      where += " AND bathrooms >= ?";
      args.add(numBathrooms);
    }

    final rows = await db.query(table, where: where, whereArgs: args);
    return rows.map((r) => PropertyListing.fromJson(r)).toList();
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings() async {
    await _ensureCachesLoaded();
    final myIds = _myListingIdsCache!;
    if (myIds.isEmpty) {
      return {
        "active": const [],
        "inactive": const [],
      };
    }

    final placeholders = List.filled(myIds.length, '?').join(',');
    final rows = await db.query(
      table,
      where: "id IN ($placeholders)",
      whereArgs: myIds.toList(),
    );
    final list = rows.map((r) => PropertyListing.fromJson(r)).toList();

    return {
      "active": list.where((e) => e.isOnline).toList(),
      "inactive": list.where((e) => !e.isOnline).toList(),
    };
  }

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
  }) async {
    String where = "1=1";
    List<Object?> args = [];

    if (query != null && query.isNotEmpty) {
      where += " AND title LIKE ?";
      args.add("%$query%");
    }
    if (listingType != null) {
      where += " AND classification = ?";
      args.add(listingType);
    }

    where += " AND is_online = 1";

    final rows = await db.rawQuery("""
      SELECT * FROM $table 
      WHERE $where
      ORDER BY created_at DESC
      LIMIT 20
    """, args);

    return rows.map((r) => PropertyListing.fromJson(r)).toList();
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings() async {
    final rows = await db.query(table, where: "is_boosted = ?", whereArgs: [1]);

    return rows.map((r) => PropertyListing.fromJson(r)).toList();
  }

  // ----------------------------------------------------------------
  // SAVED LISTINGS — dummy list ONLY (as requested)
  // ----------------------------------------------------------------

  @override
  Future<List<PropertyListing>> getSavedListings() async {
    await _ensureCachesLoaded();
    final savedIds = _savedIdsCache!;
    if (savedIds.isEmpty) return [];

    final placeholders = List.filled(savedIds.length, '?').join(',');
    final rows = await db.query(
      table,
      where: "id IN ($placeholders)",
      whereArgs: savedIds.toList(),
    );

    return rows.map((r) => PropertyListing.fromJson(r)).toList();
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    await _ensureCachesLoaded();
    return Set<int>.from(_savedIdsCache!);
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
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
  Future<PropertyListing?> getListingById(int id) async {
    final rows = await db.query(table, where: "id = ?", whereArgs: [id]);
    if (rows.isNotEmpty) {
      return PropertyListing.fromJson(rows.first);
    }
    return null;
  }
}
