import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/services/findar_api_service.dart';

class RemoteListingRepository implements ListingRepository {
  final FindarApiService apiService;

  RemoteListingRepository(this.apiService);

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
    throw UnimplementedError();
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
    // Implementation for editing a listing using the API service
    // ...
    throw UnimplementedError();
  }

  @override
  Future<ReturnResult> deleteListing(int id) async {
    // Implementation for deleting a listing using the API service
    // ...
    throw UnimplementedError();
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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings() async {
    throw UnimplementedError();
  }

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings() async {
    throw UnimplementedError();
  }

  @override
  Future<List<PropertyListing>> getSavedListings() async {
    throw UnimplementedError();
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    throw UnimplementedError();
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    throw UnimplementedError();
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    throw UnimplementedError();
  }

  @override
  Future<PropertyListing?> getListingById(int id) async {
    throw UnimplementedError();
  }
}
