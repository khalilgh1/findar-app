import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/listings_repository.dart';
import 'package:findar/core/services/api_service.dart';

/// MyListingsCubit handles user's own property listings
/// State: {data: [], state: 'loading|done|error', message: ''}
class MyListingsCubit extends Cubit<Map<String, dynamic>> {
  late final ListingsRepository listingsRepository;

  MyListingsCubit()
      : super({
          'data': [],
          'state': 'initial',
          'message': '',
        }) {
    listingsRepository = ListingsRepository(apiService: ApiService());
  }

  /// Fetch all listings created by current user
  Future<void> fetchMyListings() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingsRepository.fetchUserListings();

      if (result.state) {
        // Mock user listings
        final mockListings = [
          {
            'id': '1',
            'title': 'Beautiful Apartment in Downtown',
            'price': '\$50,000',
            'location': 'Downtown',
            'imageUrl': 'assets/find-dar-test1.jpg',
            'beds': 3,
            'baths': 2,
            'sqft': 1500,
            'isSaved': false,
            'status': 'Online',
          },
          {
            'id': '2',
            'title': 'Cozy Studio Near Beach',
            'price': '\$30,000',
            'location': 'Beach Area',
            'imageUrl': 'assets/find-dar-test2.jpg',
            'beds': 1,
            'baths': 1,
            'sqft': 800,
            'isSaved': false,
            'status': 'Online',
          },
        ];

        emit({
          ...state,
          'data': mockListings,
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

  /// Update a listing
  Future<void> updateListing(
    int listingId, {
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? image,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingsRepository.updateListing(
        listingId,
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        image: image,
      );

      if (result.state) {
        // Reload listings after update
        await fetchMyListings();
        emit({
          ...state,
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
        'message': 'Error updating listing: ${e.toString()}',
      });
    }
  }

  /// Delete a listing
  Future<void> deleteListing(int listingId) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingsRepository.deleteListing(listingId);

      if (result.state) {
        // Remove from list
        final currentData = state['data'] as List;
        final updatedData = currentData
            .where((item) => item['id'] != listingId)
            .toList();

        emit({
          ...state,
          'data': updatedData,
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
        'message': 'Error deleting listing: ${e.toString()}',
      });
    }
  }

  /// Toggle listing status (active/inactive)
  Future<void> toggleListingStatus(int listingId) async {
    try {
      final currentData = state['data'] as List;
      final listing =
          currentData.firstWhere((item) => item['id'] == listingId);
      final currentStatus = listing['status'] as String;
      final newStatus = currentStatus == 'active' ? 'inactive' : 'active';

      // Update locally (mock)
      final updatedListing = {...listing, 'status': newStatus};
      final updatedData = currentData.map((item) {
        return item['id'] == listingId ? updatedListing : item;
      }).toList();

      emit({
        ...state,
        'data': updatedData,
        'message': 'Listing status updated to $newStatus',
      });
    } catch (e) {
      emit({
        ...state,
        'message': 'Error updating status: ${e.toString()}',
      });
    }
  }
}
