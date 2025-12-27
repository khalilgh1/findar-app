import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/config/api_config.dart';

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
    try {
      final queryParams = <String, dynamic>{};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (listingType != null && listingType.isNotEmpty) {
        queryParams['listing_type'] = listingType;
      }
      print('🔴🔴🔴');
      print('Fetching recent listings with params: $queryParams');

      final response = await apiService.get(
        ApiConfig.recentListings,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      print('🔵🔵🔵');
      print('Response from recent listings: $response');
      print(response.runtimeType);

      // Expecting a JSON list from the backend
      if (response is List) {
        try {
          return response.map((e) {
            final data = Map<String, dynamic>.from(e as Map);

            // Map backend field names to model field names
            data['image'] = data['main_pic'] ?? '';
            data['isOnline'] = data['active'] ?? true;
            data['isBoosted'] = data['boosted'] ?? false;

            // For location, use a placeholder since backend doesn't provide it
            if (!data.containsKey('location')) {
              data['location'] = 'Unknown';
            }

            print('Parsing listing: ${data['title']}');
            return PropertyListing.fromJson(data);
          }).toList();
        } catch (e) {
          print('Error parsing listings: $e');
          return <PropertyListing>[];
        }
      }

      // If the API returned an error-shaped object, return empty list
      return <PropertyListing>[];
    } catch (e) {
      print('Error fetching recent listings: $e');
      return <PropertyListing>[];
    }
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
