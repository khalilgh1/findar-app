import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// PropertyDetailsCubit handles displaying detailed information about a property
/// State: {data: {}, state: 'loading|done|error', message: ''}
class PropertyDetailsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository? listingsRepository;

  PropertyDetailsCubit({this.listingsRepository})
      : super({
          'data': {},
          'state': 'initial',
          'message': '',
        });

  /// Fetch property details by ID
  Future<void> fetchPropertyDetails(int propertyId) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Mock property details
      final mockProperty = {
        'id': propertyId,
        'title': 'Beautiful Apartment in Downtown',
        'description':
            'Spacious apartment with modern amenities, fully furnished',
        'price': '\$50,000',
        'address': 'Downtown',
        'bedrooms': 3,
        'bathrooms': 2,
        'sqft': '1,500 sqft',
        'images': [
          'assets/find-dar-test1.jpg',
          'assets/find-dar-test2.jpg',
          'assets/find-dar-test3.jpg',
        ],
        'agentName': 'John Doe',
        'agentCompany': 'Prestige Realty',
        'agentImage': 'assets/profile.jpg',
        'isSaved': false,
        'similarProperties': [],
      };

      await Future.delayed(const Duration(milliseconds: 800));

      emit({
        ...state,
        'data': mockProperty,
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
    if (listingsRepository == null) return;
    
    try {
      final currentData = state['data'] as Map<String, dynamic>;
      final isSaved = currentData['isFavorite'] as bool? ?? false;

      if (isSaved) {
        // Remove from saved
        await listingsRepository!.unsaveListing(propertyId);
        emit({
          ...state,
          'data': {
            ...currentData,
            'isFavorite': false,
          },
          'message': 'Removed from favorites',
        });
      } else {
        // Add to saved
        await listingsRepository!.saveListing(propertyId);
        emit({
          ...state,
          'data': {
            ...currentData,
            'isFavorite': true,
          },
          'message': 'Added to favorites',
        });
      }
    } catch (e) {
      emit({
        ...state,
        'message': 'Error toggling favorite: ${e.toString()}',
      });
    }
  }

  /// Report/flag inappropriate listing
  Future<void> reportListing({
    required int propertyId,
    required String reason,
    String? description,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Mock report submission
      await Future.delayed(const Duration(milliseconds: 800));

      emit({
        ...state,
        'state': 'done',
        'message': 'Report submitted successfully',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
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

      emit({
        ...state,
        'similar': similarProperties,
      });
    } catch (e) {
      emit({
        ...state,
        'message': 'Error fetching similar properties: ${e.toString()}',
      });
    }
  }
}
