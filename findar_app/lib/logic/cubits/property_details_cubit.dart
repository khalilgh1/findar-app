import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// PropertyDetailsCubit handles displaying detailed information about a property
/// State: {data: {}, state: 'loading|done|error', message: ''}
class PropertyDetailsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository listingsRepository;

  PropertyDetailsCubit(this.listingsRepository)
    : super({'data': {}, 'state': 'initial', 'message': ''});

  /// Fetch property details by ID
  Future<void> fetchPropertyDetails(int propertyId) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // get property details from repository
      final property = await listingsRepository.getListingById(propertyId);

      await Future.delayed(const Duration(milliseconds: 800));

      emit({
        ...state,
        'data': property != null ? property.toJson() : {},
        'state': 'done',
        'message': 'Property details loaded successfully',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error loading property details: ${e.toString()}',
      });
    }
  }

  /// Save/unsave property to favorites
  Future<void> toggleSaveListing(int propertyId) async {
    try {
      final currentData = state['data'] as Map<String, dynamic>;
      final isSaved = currentData['isFavorite'] as bool? ?? false;

      if (isSaved) {
        // Remove from saved
        final result = await listingsRepository.unsaveListing(propertyId);

        if (result.state) {
          emit({
            ...state,
            'data': {...currentData, 'isFavorite': false},
            'message': result.message,
          });
        } else {
          emit({...state, 'message': result.message});
        }
      } else {
        // Add to saved
        final result = await listingsRepository.saveListing(propertyId);

        if (result.state) {
          emit({
            ...state,
            'data': {...currentData, 'isFavorite': true},
            'message': result.message,
          });
        } else {
          emit({...state, 'message': result.message});
        }
      }
    } catch (e) {
      emit({...state, 'message': 'Error toggling favorite: ${e.toString()}'});
    }
  }

  Future<void> reportListing({
    required int propertyId,
    required String reason,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      emit({
        ...state,
        'reportState': 'success',
      });

      await Future.delayed(const Duration(milliseconds: 100));
      emit({
        ...state,
        'reportState': 'idle',
      });
    } catch (e) {
      emit({
        ...state,
        'reportState': 'error',
        'message': 'Error submitting report: ${e.toString()}',
      });
    }
  }

  /// Get similar properties
  Future<void> getSimilarProperties(int propertyId) async {
    try {
      // Mock similar properties
      final similarProperties = [
        {
          'id': propertyId + 1,
          'title': 'Cozy Studio Near Beach',
          'price': 30000,
          'location': 'Beach Area',
          'image': 'assets/find-dar-test2.jpg',
        },
        {
          'id': propertyId + 2,
          'title': 'Modern Apartment Downtown',
          'price': 45000,
          'location': 'Downtown',
          'image': 'assets/find-dar-test3.jpg',
        },
      ];

      emit({...state, 'similar': similarProperties});
    } catch (e) {
      emit({
        ...state,
        'message': 'Error fetching similar properties: ${e.toString()}',
      });
    }
  }
}
