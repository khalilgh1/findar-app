import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// ListingsCubit handles fetching and managing property listings
/// 
/// State structure:
/// {
///   'data': List<Listing>,        // All listings
///   'state': 'loading|done|error',
///   'message': 'success or error message'
/// }
class ListingsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository listingsRepository;

  ListingsCubit(this.listingsRepository) : super({
    'data': [],
    'state': 'loading',
    'message': ''
  }) {
    // Auto-load listings when cubit is created
    fetchListings();
  }

  /// Fetch all listings (with optional filters)
  Future<void> fetchListings({
    String? location,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
  }) async {
    emit({
      ...state,
      'state': 'loading',
      'message': ''
    });

    try {
      final listings = await listingsRepository.getFilteredListings(
        minPrice: minPrice,
        maxPrice: maxPrice,
        buildingType: propertyType,
      );

      // Success: listings fetched
      emit({
        ...state,
        'data': listings,
        'state': 'done',
        'message': 'Listings fetched successfully',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error fetching listings: ${e.toString()}',
      });
    }
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    await fetchListings();
  }

  /// Save a listing to favorites
  Future<void> saveListing(int listingId) async {
    try {
      await listingsRepository.saveListing(listingId);
      // Optionally refresh listings after saving
    } catch (e) {
      emit({
        ...state,
        'message': 'Error saving listing: ${e.toString()}',
      });
    }
  }

  /// Remove a listing from favorites
  Future<void> unsaveListing(int listingId) async {
    try {
      await listingsRepository.unsaveListing(listingId);
      // Optionally refresh listings after unsaving
    } catch (e) {
      emit({
        ...state,
        'message': 'Error unsaving listing: ${e.toString()}',
      });
    }
  }

  String get stateType => state['state'] as String;
  String get message => state['message'] as String;
  List get listings => state['data'] as List;
}
