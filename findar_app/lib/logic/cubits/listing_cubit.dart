import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/repositories/listing_repository.dart';
import '../../core/services/api_service.dart';

/// ListingCubit handles user listing operations
/// State: {data: List<Listing>, state: 'loading|done|error', message: ''}
class ListingCubit extends Cubit<Map<String, dynamic>> {
  late final ListingRepository listingRepository;

  ListingCubit()
      : super({
          'data': [],
          'state': 'initial',
          'message': '',
        }) {
    listingRepository = ListingRepository(apiService: ApiService());
  }

  /// Fetch all user listings
  Future<void> fetchUserListings() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingRepository.getUserListings();

      if (result.state) {
        final listings = listingRepository.getCachedListings();
        
        emit({
          ...state,
          'data': listings,
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
  Future<void> updateListing({
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
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingRepository.updateListing(
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
      );

      if (result.state) {
        final listings = listingRepository.getCachedListings();
        
        emit({
          ...state,
          'data': listings,
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
        'message': 'Error updating listing: ${e.toString()}',
      });
    }
  }

  /// Delete a listing
  Future<void> deleteListing(int id) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingRepository.deleteListing(id);

      if (result.state) {
        final listings = listingRepository.getCachedListings();
        
        emit({
          ...state,
          'data': listings,
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

  /// Toggle listing online/offline status
  Future<void> toggleListingStatus(int id, bool isOnline) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await listingRepository.toggleListingStatus(id, isOnline);

      if (result.state) {
        final listings = listingRepository.getCachedListings();
        
        emit({
          ...state,
          'data': listings,
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
        'message': 'Error updating status: ${e.toString()}',
      });
    }
  }

  /// Get online listings
  List<dynamic> get onlineListings {
    final listings = state['data'] as List;
    return listings.where((listing) => listing.isOnline == true).toList();
  }

  /// Get offline listings
  List<dynamic> get offlineListings {
    final listings = state['data'] as List;
    return listings.where((listing) => listing.isOnline == false).toList();
  }

  /// Update listing boost status locally (for simulated boost without backend)
  void updateBoostStatus({
    required int listingId,
    required String sponsorshipPlanId,
    required DateTime boostExpiryDate,
  }) {
    final listings = List<dynamic>.from(state['data'] as List);
    
    final index = listings.indexWhere((listing) => listing.id == listingId);
    
    if (index != -1) {
      final updatedListing = listings[index].copyWith(
        isBoosted: true,
        sponsorshipPlanId: sponsorshipPlanId,
        boostExpiryDate: boostExpiryDate,
      );
      
      listings[index] = updatedListing;
      
      emit({
        ...state,
        'data': listings,
      });
    }
  }
}
