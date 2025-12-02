import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/listings_repository.dart';
import 'package:findar/core/services/api_service.dart';

/// ListingsCubit handles fetching and managing property listings
/// 
/// State structure:
/// {
///   'data': List<Listing>,        // All listings
///   'state': 'loading|done|error',
///   'message': 'success or error message'
/// }
class ListingsCubit extends Cubit<Map<String, dynamic>> {
  late final ListingsRepository listingsRepository;

  ListingsCubit() : super({
    'data': [],
    'state': 'loading',
    'message': ''
  }) {
    listingsRepository = ListingsRepository(apiService: ApiService());
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
      final result = await listingsRepository.fetchListings(
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        propertyType: propertyType,
      );

      if (result.state) {
        // Note: In real implementation, we'd parse the API response
        // For now, mock data is returned by apiService
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
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

  /// Get user's own listings
  Future<void> fetchUserListings() async {
    emit({
      ...state,
      'state': 'loading',
      'message': ''
    });

    try {
      final result = await listingsRepository.fetchUserListings();

      if (result.state) {
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error fetching user listings: ${e.toString()}',
      });
    }
  }

  /// Save a listing to favorites
  Future<void> saveListing(int listingId) async {
    try {
      final result = await listingsRepository.saveListing(listingId);

      if (!result.state) {
        emit({
          ...state,
          'message': result.message,
        });
      }
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
      final result = await listingsRepository.unsaveListing(listingId);

      if (!result.state) {
        emit({
          ...state,
          'message': result.message,
        });
      }
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
